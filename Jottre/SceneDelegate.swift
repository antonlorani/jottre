//
//  SceneDelegate.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import OSLog

/// - Make the Settings of this App globally available
let settings: Settings = Settings()

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var retainedRootCoordinator: RootCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let localizableStringsDataSource = LocalizableStringsDataSource()
        let navigationController = RootNavigationController()
        let rootCoordinator = RootCoordinator(
            navigationController: navigationController,
            repository: RootCoordinatorRepository(localizableStringsDataSource: localizableStringsDataSource),
            deviceEnvironmentDataSource: DeviceEnvironmentDataSource(device: UIDevice.current),
            cloudDataSource: CloudDataSource(fileManager: FileManager.default),
            localizableStringsDataSource: localizableStringsDataSource
        )
        retainedRootCoordinator = rootCoordinator

        let newWindow = UIWindow()
        newWindow.windowScene = windowScene
        newWindow.rootViewController = navigationController
        newWindow.makeKeyAndVisible()
        window = newWindow
        rootCoordinator.start()
        hideToolbarIfNeeded(windowScene: windowScene)

        /*
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange(_:)), name: Settings.didUpdateNotificationName, object: nil)
         */

        /*
        presentDocument(urlContext: connectionOptions.urlContexts)
        
        settings.didUpdate()
        
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            configure(window: window, with: userActivity)
        }
        */
    }

    private func hideToolbarIfNeeded(windowScene: UIWindowScene) {
        #if targetEnvironment(macCatalyst)
        windowScene.titlebar?.toolbar?.isVisible = false
        windowScene.titlebar?.titleVisibility = .hidden
        #endif
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
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
    
    
    
    // MARK: - Observer methods
    
    @objc func settingsDidChange(_ notification: Notification) {
        
        guard let window = window, let updatedSettings = notification.object as? Settings else { return }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.overrideUserInterfaceStyle = updatedSettings.preferredUserInterfaceStyle()
        }, completion: nil)
        
    }
    
    
    
    // MARK: - Drag methods
    
    func configure(window: UIWindow?, with activity: NSUserActivity) {

        if activity.title == Node.NodeOpenDetailPath {

            if let nodeURL = activity.userInfo?[Node.NodeOpenDetailActivityType] as? URL {
               
                let node = Node(url: nodeURL)
                node.pull { (success) in
                    if !success { return }
                
                    DispatchQueue.main.async {
                        
                        let drawViewController = DrawViewController(node: node)
                        
                        if let navigationController = window?.rootViewController as? UINavigationController {
                            navigationController.pushViewController(drawViewController, animated: true)
                        }
                        
                    }
                
                }
                
            }
            
        }
        
    }
    
    
}

