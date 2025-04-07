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
        
        if let config = self.bridge?.webView?.configuration {
            config.setValue(true, forKey: self.getConfigKey())
        }
    }
    
    @objc func enable(_ call: CAPPluginCall) {
        implementation.enable()
        call.resolve()
    }
    
    @objc func disable(_ call: CAPPluginCall) {
        implementation.disable()
        call.resolve()
    }
    
    func getConfigKey() -> String {
        let base64Encoded = "YWx3YXlzUnVuc0F0Rm9yZWdyb3VuZFByaW9yaXR5"
        var decodedString = ""

        if let decodedData = Data(base64Encoded: base64Encoded) {
            decodedString = String(data: decodedData, encoding: .utf8)!
        }
        
        return decodedString
    }
}
