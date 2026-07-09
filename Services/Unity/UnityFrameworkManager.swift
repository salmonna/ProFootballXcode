//
//  UnityFrameworkManager.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import Foundation
import UIKit
import UnityFramework

class UnityFrameworkManager: NSObject, UnityFrameworkListener {
    
    static let shared = UnityFrameworkManager()
    private var ufw: UnityFramework?
    private var hostWindow: UIWindow?

    private func isUnityInitialized() -> Bool {
        return ufw != nil && ufw?.appController() != nil
    }

    func initUnity() {
        if isUnityInitialized() { return }
        
        // תיקון ל-iOS 15+: מציאת ה-Window דרך ה-Scene
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            self.hostWindow = scene.windows.first
        } else {
            self.hostWindow = UIApplication.shared.windows.first
        }
        
        let bundlePath = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        guard let bundle = Bundle(path: bundlePath) else {
            print("❌ UnityFrameworkManager: Framework not found")
            return
        }
        if !bundle.isLoaded { bundle.load() }
        
        guard let ufwInstance = bundle.principalClass?.getInstance() else {
            print("❌ UnityFrameworkManager: Instance failed")
            return
        }
        self.ufw = ufwInstance
        
        self.ufw?.setDataBundleId(Bundle.main.bundleIdentifier)
        self.ufw?.register(self)
        
        self.ufw?.runEmbedded(withArgc: CommandLine.argc,
                             argv: CommandLine.unsafeArgv,
                             appLaunchOpts: nil)
        
        setupHiddenUnityView()
    }

    private func setupHiddenUnityView() {
        DispatchQueue.main.async {
            guard let ufw = self.ufw, let unityView = ufw.appController()?.rootView else { return }
            
            unityView.isUserInteractionEnabled = false
            unityView.isHidden = true
            unityView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            unityView.alpha = 0.01
            
            self.hostWindow?.insertSubview(unityView, at: 0)
            self.fixWindowHierarchy()
        }
    }

    private func fixWindowHierarchy() {
        if let unityWindow = ufw?.appController()?.window {
            unityWindow.isHidden = true
            unityWindow.isUserInteractionEnabled = false
        }
        self.hostWindow?.makeKeyAndVisible()
        print("✅ Unity is running silently in the background")
    }

    func sendMessage(toObject: String, method: String, message: String) {
        if isUnityInitialized() {
            ufw?.sendMessageToGO(withName: toObject, functionName: method, message: message)
        }
    }
    
    func unityFrameworkDidBecomeActive(_ notification: Notification!) {
        fixWindowHierarchy()
    }
}
