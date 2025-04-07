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
        self.configureAudioPlayer()
        self.configureAudioSession()
        self.observeLifeCycle()
    }
    
    public func enable() {
        if self.enabled { return }
        self.enabled = true
    }
    
    public func disable() {
        if self.enabled { return }
        self.enabled = false
        self.stopKeepingAwake()
    }
    
    func configureAudioPlayer() {
        guard let url = Bundle(for: BackgroundModePlugin.self)
            .url(forResource: "appbeep", withExtension: "wav") else {
            print("Didn't load audio file")
            self.plugin.notifyListeners("error", data: ["message": "Didn't load audio file"])
            return
        }
        
        do {
            let audioPlayer = try AVAudioPlayer.init(contentsOf: url)
            
            audioPlayer.volume = 0
            audioPlayer.numberOfLoops = -1
            
            self.audioPlayer = audioPlayer
        } catch {
            print("Audio error: \(error).")
            self.plugin.notifyListeners("error", data: ["message": error.localizedDescription])
        }
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Audio error: \(error).")
            self.plugin.notifyListeners("error", data: ["message": error.localizedDescription])
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
        if !self.enabled { return }
        self.audioPlayer?.play()
        self.plugin.notifyListeners("appInBackground", data: [:])
    }
    
    @objc private func stopKeepingAwake() {
        if self.audioPlayer?.isPlaying == true {
            self.plugin.notifyListeners("appInForeground", data: [:])
        }
        
        self.audioPlayer?.pause()
    }
    
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        self.plugin.notifyListeners("interrupted", data: [:])
        self.keepAwake()
    }
}
