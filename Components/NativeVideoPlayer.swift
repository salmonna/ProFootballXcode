//
//  NativeVideoPlayer.swift
//  ProFootball
//
//  Created by Soli Nagosa on 10/05/2026.
//

import SwiftUI
import AVKit

// Wrapper ל-AVPlayerViewController הנייטיב של אפל
struct NativeVideoPlayer: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        controller.player?.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        let parent: NativeVideoPlayer
        init(_ parent: NativeVideoPlayer) { self.parent = parent }

        func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {}

        func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {
            // כשהמשתמש לוחץ X - סוגרים את ה-sheet
            coordinator.animate(alongsideTransition: nil) { _ in
                self.parent.isPresented = false
            }
        }
    }
}
