//
//  NativeRecorderBridge.swift
//  ProFootball
//
import Foundation
import Metal

@_cdecl("startNativeRecording")
func startNativeRecording(_ width: Int32, _ height: Int32) {
    print("📞 startNativeRecording called: \(width)x\(height)")
    // אתחול מיידי
    SwiftRecorder.shared.startWithWidth(Int(width), height: Int(height))
}

@_cdecl("sendFrameToNative")
func sendFrameToNative(_ texturePtr: UnsafeMutableRawPointer?) {
    guard let ptr = texturePtr else { return }
    
    // המרה בטוחה ל-MTLTexture
    let texture = unsafeBitCast(ptr, to: MTLTexture.self)
    SwiftRecorder.shared.processFrame(texture)
}

@_cdecl("stopNativeRecording")
func stopNativeRecording() {
    print("🛑 stopNativeRecording called")
    SwiftRecorder.shared.stop()
}
