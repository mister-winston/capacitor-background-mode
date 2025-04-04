import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(BackgroundModePlugin)
public class BackgroundModePlugin: CAPPlugin {
    private lazy var implementation = BackgroundMode(plugin: self)
    
    override public func load() {
        super.load()
        implementation.load()
    }
    
    @objc func enable(_ call: CAPPluginCall) {
        implementation.enable()
        call.resolve()
    }
    
    @objc func disable(_ call: CAPPluginCall) {
        implementation.disable()
        call.resolve()
    }
}
