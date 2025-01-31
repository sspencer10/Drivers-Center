/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
`CarPlaySceneDelegate` is the delegate for the `CPTemplateApplicationScene` on the CarPlay display.
*/
/*
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    </array>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UISceneConfigurations</key>
        <dict>
            <key>CPTemplateApplicationSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneClassName</key>
                    <string>CPTemplateApplicationScene</string>
                    <key>UISceneConfigurationName</key>
                    <string>CarPlay Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>$(PRODUCT_MODULE_NAME).CarPlaySceneDelegate</string>
                </dict>
            </array>
        </dict>
    </dict>
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>location</string>
        <string>processing</string>
    </array>
</dict>
</plist>
*/

import CarPlay
import UIKit
import SwiftUI

/// `CarPlaySceneDelegate` is the UIScenDelegate and CPCarPlaySceneDelegate.
class CarPlaySceneDelegate: NSObject, ObservableObject {
    
    
    
    /// The template manager handles the connection to CarPlay and manages the displayed templates.
    let templateManager = TemplateManager.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if scene is CPTemplateApplicationScene, session.configuration.name == "TemplateSceneConfiguration" {
            print("Template application scene will connect.")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        if scene.session.configuration.name == "TemplateSceneConfiguration" {
            print("Template application scene did disconnect.")
            
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        if scene.session.configuration.name == "TemplateSceneConfiguration" {
            print("Template application scene did become active.")
            //UserDefaults.standard.setValue(true, forKey: "isCarPlay")
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        if scene.session.configuration.name == "TemplateSceneConfiguration" {
            print("Template application scene will resign active.")
        }
    }
    
}

// MARK: CPCarPlaySceneDelegate

extension CarPlaySceneDelegate: CPTemplateApplicationSceneDelegate {
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        print("Template application scene did connect.")
        templateManager.connect(interfaceController, scene: templateApplicationScene)
        LocationManager.shared.lm.startUpdatingLocation()
        LocationManager.shared.lm.startUpdatingHeading()
        let maxItemCount = CPListTemplate.maximumItemCount
        print("Maximum items allowed: \(maxItemCount)")
        UserDefaults.standard.set(maxItemCount, forKey: "maxItemCount")
        MediaItemViewModel.shared.start()
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        templateManager.disconnect()
        print("Template application scene did disconnect.")
        MediaItemViewModel.shared.stop()
    }
}

