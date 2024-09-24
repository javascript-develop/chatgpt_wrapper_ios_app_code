//
//  Utils.swift
//  GenieD
//
//  Created by OK on 28.02.2023.
//

import Foundation
import SwiftUI
import StoreKit

struct Utils {
    static var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var keyWindow: UIWindow? {
        UIApplication.shared.keyWindow
    }
    
    static var appVersion: String? {
        guard let version =  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) - \(build)"
        }
        
        return version
    }
    
    static func shareApp() {
        let message = "GenieD"
        let link = NSURL(string: Constants.Link.iTunesUrl)!
        let data = [message, link] as [Any]
        UIApplication.share(data)
    }
    
    static func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    static func writeReview() {
       var components = URLComponents(url: URL(string: Constants.Link.iTunesUrl)!, resolvingAgainstBaseURL: false)
       components?.queryItems = [
         URLQueryItem(name: "action", value: "write-review")
       ]
       guard let writeReviewURL = components?.url else {
         return
       }
       UIApplication.shared.open(writeReviewURL)
    }
    
    static func onLinkAction(link: URL) {
        if UIApplication.shared.canOpenURL(link) {
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        }
    }
    
    static func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func shareText(_ text: String) {
        let objectsToShare = [text] as [Any]
        UIApplication.share(objectsToShare)
    }
    
    static func shareImage(_ image: UIImage) {
        let objectsToShare = [image] as [Any]
        UIApplication.share(objectsToShare)
    }
    
    static func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
    }
    
    static func resizeImage(image: UIImage) -> UIImage? {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        let maxHeight: Float = 512.0//todo: //check size
        let maxWidth: Float = 512.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5//todo: //check value

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        let rect = CGRectMake(0.0, 0.0, CGFloat(actualWidth), CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        
        guard let imageData = imageData else { return nil }
        
        return UIImage(data: imageData)
    }
}
