//
//  SwiftRecorder.swift
//  ProFootball
//
//  Created by Soli Nagosa on 08/05/2026.
//
import Foundation
import AVFoundation
import Metal
import UIKit


@objcMembers
public class SwiftRecorder: NSObject {
    @objc static let shared = SwiftRecorder()
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var adapter: AVAssetWriterInputPixelBufferAdaptor?
    private var isRecording = false
    private var startTime: CFTimeInterval = 0
    private let recordingQueue = DispatchQueue(label: "com.profootball.recorder.queue", qos: .userInitiated)


    private override init() { super.init() }

    @objc func startWithWidth(_ width: Int, height: Int) {
        guard !isRecording else { return }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileURL = documentsURL.appendingPathComponent("Football_Exercise_\(timestamp).mp4")

        do {
            assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: .mp4)
            
            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height
            ]
            
            assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            // היפוך אנכי של הקלט כדי להתאים לרינדור של יוניטי
            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: CGFloat(-height))
            assetWriterInput?.transform = transform
            assetWriterInput?.expectsMediaDataInRealTime = true
            
            adapter = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: assetWriterInput!,
                sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                    kCVPixelBufferWidthKey as String: width,
                    kCVPixelBufferHeightKey as String: height,
                    kCVPixelBufferMetalCompatibilityKey as String: true
                ]
            )
            
            if assetWriter!.canAdd(assetWriterInput!) {
                assetWriter?.add(assetWriterInput!)
            }
            
            assetWriter?.startWriting()
            assetWriter?.startSession(atSourceTime: .zero)
            
            isRecording = true
            startTime = CACurrentMediaTime()
            print("🎥 Recorder: Started saving to \(fileURL.lastPathComponent)")
        } catch {
            print("❌ Recorder Start Error: \(error)")
        }
    }

    @objc func processFrame(_ texture: MTLTexture) {
        // שיפור: לוקחים snapshot של הזמן לפני ה-async
        let frameTime = CACurrentMediaTime() - self.startTime
        
        recordingQueue.async { [weak self] in
            guard let self = self, self.isRecording,
                  let adapter = self.adapter,
                  self.assetWriterInput?.isReadyForMoreMediaData == true else { return }

            let presentationTime = CMTime(seconds: frameTime, preferredTimescale: 600)

            if let pixelBuffer = self.makePixelBuffer(from: texture) {
                adapter.append(pixelBuffer, withPresentationTime: presentationTime)
            }
        }
    }

    @objc func stop() {
        recordingQueue.async { [weak self] in
            guard let self = self, self.isRecording else { return }

            print("🎬 Recorder: Stop requested, finishing writing...")
            self.isRecording = false
            self.assetWriterInput?.markAsFinished()

            self.assetWriter?.finishWriting { [weak self] in
                let status = self?.assetWriter?.status
                if status == .completed {
                    if let url = self?.assetWriter?.outputURL {
                        print("✅ Recorder: Video saved successfully at \(url.path)")
                    }
                    
                } else {
                    print("❌ Writer failed with status: \(status?.rawValue ?? -1)")
                    if let error = self?.assetWriter?.error {
                        print("❌ Writer Error: \(error.localizedDescription)")
                    }
                    
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .videoCreationFinished, object: nil)
                }
                
                self?.assetWriter = nil
                self?.assetWriterInput = nil
                self?.adapter = nil
            }
        }
    }

    private func makePixelBuffer(from texture: MTLTexture) -> CVPixelBuffer? {
        let width = texture.width
        let height = texture.height
        let bytesPerRow = width * 4

        let device = texture.device
        
        // ✅ קריאה בטוחה ל-iOS: מעתיקים לבאפר CPU-accessible דרך blit
        guard let commandQueue = device.makeCommandQueue(),
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("❌ Failed to create Metal command infrastructure")
            return nil
        }

        let bufferSize = bytesPerRow * height
        guard let readbackBuffer = device.makeBuffer(length: bufferSize,
                                                      options: .storageModeShared) else {
            print("❌ Failed to create readback buffer")
            return nil
        }

        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            print("❌ Failed to create blit encoder")
            return nil
        }

        // העתקה מהטקסטורה לבאפר ה-CPU
        blitEncoder.copy(
            from: texture,
            sourceSlice: 0,
            sourceLevel: 0,
            sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
            sourceSize: MTLSize(width: width, height: height, depth: 1),
            to: readbackBuffer,
            destinationOffset: 0,
            destinationBytesPerRow: bytesPerRow,
            destinationBytesPerImage: bufferSize
        )
        blitEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted() // ✅ ממתין ל-GPU בצורה תקינה ב-iOS

        // יצירת PixelBuffer מהבאפר שקראנו
        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary

        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width, height,
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess, let pb = pixelBuffer else {
            print("❌ Failed to create PixelBuffer")
            return nil
        }

        CVPixelBufferLockBaseAddress(pb, [])
        if let dest = CVPixelBufferGetBaseAddress(pb) {
            let destBytesPerRow = CVPixelBufferGetBytesPerRow(pb)
            let src = readbackBuffer.contents()

            // העתקה שורה-שורה כי ה-destBytesPerRow עלול להיות שונה מ-width*4
            for row in 0..<height {
                let srcRow = src.advanced(by: row * bytesPerRow)
                let dstRow = dest.advanced(by: row * destBytesPerRow)
                memcpy(dstRow, srcRow, bytesPerRow)
            }
        }
        CVPixelBufferUnlockBaseAddress(pb, [])

        return pb
    }
}

extension Notification.Name {
    static let videoCreationFinished = Notification.Name("videoCreationFinished")
}
