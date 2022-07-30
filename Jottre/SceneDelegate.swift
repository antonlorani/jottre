//
//  SceneDelegate.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import OSLog
import Combine

extension UIView {

    func animateTransition(newUserInterfaceStyle: UIUserInterfaceStyle) {
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.overrideUserInterfaceStyle = newUserInterfaceStyle
        }, completion: nil)
    }
}

/// - Make the Settings of this App globally available
let settings: Settings = Settings()

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var retainedRootCoordinator: RootCoordinator?
    private var userInterfaceStyleCancellable: AnyCancellable?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let navigationController = RootNavigationController()
        let rootCoordinator = RootCoordinator(
            navigationController: navigationController,
            defaults: Defaults.shared,
            repository: RootCoordinatorRepository(localizableStringsDataSource: LocalizableStringsDataSource.shared),
            deviceDataSource: DeviceDataSource(device: UIDevice.current),
            cloudDataSource: CloudDataSource(fileManager: FileManager.default),
            localizableStringsDataSource: LocalizableStringsDataSource.shared,
            openURLProvider: { url in
                UIApplication.shared.open(url)
            }
        )
        retainedRootCoordinator = rootCoordinator

        let newWindow = UIWindow()
        newWindow.windowScene = windowScene
        newWindow.rootViewController = navigationController
        newWindow.makeKeyAndVisible()
        window = newWindow
        rootCoordinator.start()
        hideToolbarIfNeeded(windowScene: windowScene)

        userInterfaceStyleCancellable = Defaults
            .shared
            .publisher(PreferredUserInterfaceStyleEntry())
            .replaceNil(with: UIUserInterfaceStyle.unspecified.rawValue)
            .compactMap(UIUserInterfaceStyle.init)
            .sink { [weak self] preferredUserInterfaceStyle in
                self?.window?.animateTransition(newUserInterfaceStyle: preferredUserInterfaceStyle)
            }

        /*
        presentDocument(urlContext: connectionOptions.urlContexts)

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

