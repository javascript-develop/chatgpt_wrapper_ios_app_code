//
//  UIApplication.swift
//  GenieD
//
//  Created by OK on 04.03.2023.
//

import UIKit


extension UIApplication {
    
    var keyWindow: UIWindow? {
            connectedScenes
                .compactMap {
                    $0 as? UIWindowScene
                }
                .flatMap {
                    $0.windows
                }
                .first {
                    $0.isKeyWindow
                }
    }
    
    class var topViewController: UIViewController? { return getTopViewController() }
    
    private class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController { return getTopViewController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController { return getTopViewController(base: selected) }
        }
        if let presented = base?.presentedViewController { return getTopViewController(base: presented) }
        return base
    }

    private class func _share(_ data: [Any],
                              applicationActivities: [UIActivity]?,
                              setupViewControllerCompletion: ((UIActivityViewController) -> Void)?) {
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        guard let topVC = topViewController else { return }
        
        if Utils.isIpad {
            activityViewController.popoverPresentationController?.sourceView = topVC.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 0.5 * UIScreen.main.bounds.width, y: UIScreen.main.bounds.height, width: 0, height: 0)
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        }
        setupViewControllerCompletion?(activityViewController)
        topVC.present(activityViewController, animated: true, completion: nil)
    }

    class func share(_ data: Any...,
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
    class func share(_ data: [Any],
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
}
