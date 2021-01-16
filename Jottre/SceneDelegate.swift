//
//  SceneDelegate.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import os.log

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)
        windowScene.titlebar?.toolbar?.isVisible = false
        windowScene.titlebar?.titleVisibility = .hidden
        #endif
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowScene = windowScene
                
        let initialController = InitialViewController()
        
        let initialNavigationController = NavigationViewController(rootViewController: initialController)
        
        window?.rootViewController = initialNavigationController
        window?.makeKeyAndVisible()
                
        presentDocument(urlContext: connectionOptions.urlContexts)
        
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        presentDocument(urlContext: URLContexts)
    }
    
    
    func presentDocument(urlContext: Set<UIOpenURLContext>) {
                      
        guard let urlContext = urlContext.first else { return }
        
        let url = urlContext.url
        _ = url.startAccessingSecurityScopedResource()
        
        let node = Node(url: url)
        node.pull { (success) in
                            
            if !success { return }
                
            DispatchQueue.main.async {
                let drawController = DrawViewController(node: node)
                self.window?.rootViewController?.children[0].navigationController?.pushViewController(drawController, animated: true)
            }
                
        }
        
    }

    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

