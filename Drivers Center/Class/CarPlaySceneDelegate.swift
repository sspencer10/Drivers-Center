/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
`CarPlaySceneDelegate` is the delegate for the `CPTemplateApplicationScene` on the CarPlay display.
*/
/*
import CarPlay
import UIKit

/// `CarPlaySceneDelegate` is the UIScenDelegate and CPCarPlaySceneDelegate.
class CarPlaySceneDelegate: NSObject {
    
    /// The template manager handles the connection to CarPlay and manages the displayed templates.
    let templateManager = TemplateManager()
    
    // MARK: UISceneDelegate
    
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
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        templateManager.disconnect()
        print("Template application scene did disconnect.")
    }
}
*/
