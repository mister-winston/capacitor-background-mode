import Foundation
import Capacitor
import AVFAudio

// Copied from https://github.com/katzer/cordova-plugin-background-mode

@objc public class BackgroundMode: NSObject {
    private let plugin: CAPPlugin
    private var enabled = false
    private var audioPlayer: AVAudioPlayer?
    
    init(plugin: CAPPlugin) {
        self.plugin = plugin
    }
    
    public func load() {
        WebViewSwizzler.swizzleWebViewEngine()
        self.configureAudioPlayer()
        self.configureAudioSession()
        self.observeLifeCycle()
    }
    
    public func enable() {
        if enabled { return }
        enabled = true
    }
    
    public func disable() {
        if enabled { return }
        enabled = false
        stopKeepingAwake()
    }
    
    func configureAudioPlayer() {
        guard let url = Bundle(for: BackgroundModePlugin.self)
            .url(forResource: "appbeep", withExtension: "wav") else {
            return
        }
        
        do {
            let audioPlayer = try AVAudioPlayer.init(contentsOf: url)
            
            audioPlayer.volume = 0
            audioPlayer.numberOfLoops = -1
            
            self.audioPlayer = audioPlayer
        } catch {
            NSLog("Audio error: \(error).")
        }
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            NSLog("Audio error: \(error).")
        }
    }
    
    private func observeLifeCycle() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(keepAwake),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(stopKeepingAwake),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAudioSessionInterruption(_:)),
                                       name: AVAudioSession.interruptionNotification,
                                       object: nil)
    }
    
    @objc private func keepAwake() {
        if !enabled { return }
        audioPlayer?.play()
        self.plugin.notifyListeners("activate", data: [:])
    }
    
    @objc private func stopKeepingAwake() {
        if audioPlayer?.isPlaying == true {
            self.plugin.notifyListeners("deactivate", data: [:])
        }
        
        audioPlayer?.pause()
    }
    
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        self.plugin.notifyListeners("deactivate", data: [:])
        keepAwake()
    }
}
