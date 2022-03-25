import Flutter
import UIKit
import Photos
import MobileCoreServices
import StoreKit

let INSTAGRAM_SCHEME: String = "instagram://"
let FACEBOOK_SCHEME: String = "facebook-stories://"

let INSTAGRAM_ID: String = "389801252"
let FACEBOOK_ID: String = "284882215"


extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    var containsImage: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }
    var containsAudio: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
    var containsVideo: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }
    
}

public class SwiftFlutterMetaSharePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_meta_share", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMetaSharePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private var controller: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        
        switch call.method {
        case "open_instagram_store":
            result(openStore(id: INSTAGRAM_ID))
            break
        case "open_facebook_store":
            result(openStore(id: FACEBOOK_ID))
            break
        case "is_instagram_installed":
            result(isAppInstalled(scheme: INSTAGRAM_SCHEME))
            break
        case "is_facebook_installed":
            result(isAppInstalled(scheme: FACEBOOK_SCHEME))
            break
        case "share_facebook":
            if let myArgs = call.arguments as? [String: Any],
               let path = myArgs["filePath"] as? String {
                shareFacebook(filePath: path, result: result)
            }else{
                result(false)
            }
            break
        case "share_instagram":
            if let myArgs = call.arguments as? [String: Any],
               let path = myArgs["filePath"] as? String {
                shareInstagram(filePath: path, result: result)
            }else{
                result(false)
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    public func openStore(id:String) -> Bool{
        
        guard let root = UIApplication.shared.keyWindow?.rootViewController else {
            return false
        }
        
        let productViewController = SKStoreProductViewController()
        
        let params: [String: Any] = [
            SKStoreProductParameterITunesItemIdentifier: id,
        ]
        
        productViewController.loadProduct(withParameters: params, completionBlock: nil)
        
        if root.presentedViewController != nil {
            root.dismiss(animated: true) {
                root.present(productViewController, animated: true, completion: nil)
            }
        } else {
            root.present(productViewController, animated: true, completion: nil)
        }
        
        return true
        
    }
    
    public func isAppInstalled(scheme:String) -> Bool{
        let scheme = URL(string: scheme)
        if UIApplication.shared.canOpenURL(scheme!) {
            return true
        } else {
            return false
        }
    }
    
    public func shareInstagram(filePath:String, result: @escaping FlutterResult){
        
        if(!isAppInstalled(scheme: INSTAGRAM_SCHEME)){
            let flutterError = FlutterError(
                code: "error",
                message: "instagram is not installed",
                details: ""
            )
            print("error : instagram is not installed")
            result(flutterError)
            return
        }
        
        
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        
        let fileURL: URL = URL(fileURLWithPath: filePath)
        
        let activityItems = [fileURL] as [Any]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
        
        activityVC.excludedActivityTypes = [
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.mail,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
            UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
            UIActivity.ActivityType(rawValue: "com.apple.reminders.sharingextension"),
        ]
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popup = activityVC.popoverPresentationController {
                popup.sourceView = viewController?.view
                popup.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            }
        }
        viewController!.present(activityVC, animated: true, completion: nil)
        result(true)
        return
        /* DIRECT STORY SHARE API
         let documentExists = FileManager.default.fileExists(atPath: filePath)
         if(documentExists) {
         let fileURL: URL = URL(fileURLWithPath: filePath)
         var localId: String?
         
         PHPhotoLibrary.shared().performChanges({
         var request: PHAssetChangeRequest?
         if(fileURL.containsImage){
         request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
         } else if(fileURL.containsVideo){
         request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
         } else{
         let flutterError = FlutterError(
         code: "error",
         message: "file mime type error",
         details: ""
         )
         print("error : file mime type error")
         result(flutterError)
         return
         }
         localId = request?.placeholderForCreatedAsset?.localIdentifier
         }, completionHandler: { success, error in
         
         DispatchQueue.main.async {
         guard error == nil else {
         let flutterError = FlutterError(
         code: "error",
         message: "DispatchQueue error",
         details: ""
         )
         print("error : DispatchQueue error")
         result(flutterError)
         return
         }
         guard let localId = localId else {
         let flutterError = FlutterError(
         code: "error",
         message: "localId not exist",
         details: ""
         )
         print("error : localId not exist")
         result(flutterError)
         return
         }
         
         let url = URL(string: "instagram://library?LocalIdentifier=\(localId)")!
         UIApplication.shared.open(url, options: [:], completionHandler: nil)
         result(true)
         }
         })
         } else {
         let flutterError = FlutterError(
         code: "error",
         message: "document not exist",
         details: ""
         )
         print("error : document not exist")
         result(flutterError)
         return
         }
         */
    }
    
    public func shareFacebook(filePath:String, result: @escaping FlutterResult){
        if(!isAppInstalled(scheme: FACEBOOK_SCHEME)){
            let flutterError = FlutterError(
                code: "error",
                message: "facebook is not installed",
                details: ""
            )
            print("error : facebook is not installed")
            result(flutterError)
            return
        }
        
        
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        
        let fileURL: URL = URL(fileURLWithPath: filePath)
        
        let activityItems = [fileURL] as [Any]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
        
        activityVC.excludedActivityTypes = [
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.mail,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
            UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
            UIActivity.ActivityType(rawValue: "com.apple.reminders.sharingextension"),
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popup = activityVC.popoverPresentationController {
                popup.sourceView = viewController?.view
                popup.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            }
        }
        viewController!.present(activityVC, animated: true, completion: nil)
        result(true)
        return
    }
}
