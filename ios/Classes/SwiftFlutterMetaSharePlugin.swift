import Flutter
import UIKit

public class SwiftFlutterMetaSharePluginPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_meta_share", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPromotionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            switch call.method {
            case "set_promotion":
                if let myArgs = call.arguments as? [String: Any],
                   let prefer = myArgs["prefer"] as? Float,
                   let max = myArgs["max"] as? Float{
                    
                    if #available(iOS 15.0, *) {
                        let displayLink = CADisplayLink(target: self, selector: #selector(step))
                        displayLink.preferredFrameRateRange = CAFrameRateRange(minimum:60, maximum:max, preferred:prefer)
                        displayLink.add(to: .current, forMode: .default)
                    }
                    result(true)
                }else{
                    result(false)
                }
            default:
                result(false)
            }
        }catch{
            result(false)
        }
    }
    
    @objc func step(displaylink: CADisplayLink) {
        // Will be called once a frame has been built while matching desired frame rate
    }
}
