//
//  SceneDelegate.swift
//  iOSExplorer
//
//  Created by Hiroyuki Koike on 2019/10/13.
//  Copyright © 2019 Microsoft. All rights reserved.
//

import UIKit
import os.log

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var rootViewController: UINavigationController?

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        os_log("willConnectTo : %@", log: OSLog.default, type: .debug, scene.session.persistentIdentifier)

        ODClient.setMicrosoftAccountAppId("0000000048160AF8", scopes: ["onedrive.readwrite"]);

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 100, height: 50)
            let vc = ODXItemCollectionViewController.init(collectionViewLayout: layout)

            self.rootViewController = UINavigationController.init(rootViewController: vc)
            window.rootViewController = self.rootViewController

            self.window = window
            window.makeKeyAndVisible()
        }
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) { // launch:1
        os_log("sceneWillEnterForeground : %@", log: OSLog.default, type: .debug, scene.session.persistentIdentifier)
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) { // launch:2
        os_log("sceneDidBecomeActive : %@", log: OSLog.default, type: .debug, scene.session.persistentIdentifier)
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {  // launch:3
        os_log("sceneWillResignActive : %@", log: OSLog.default, type: .debug, scene.session.persistentIdentifier)
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        os_log("sceneDidEnterBackground : %@", log: OSLog.default, type: .debug, scene.session.persistentIdentifier)
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        os_log("sceneDidDisconnect : %@", log: OSLog.default, type: .debug, scene.session.persistentIdentifier)
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        os_log("scene openURLContexts : %@", log: OSLog.default, type: .debug, scene.session.persistentIdentifier)
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        os_log("scene continue : %@", log: OSLog.default, type: .debug, scene.session.persistentIdentifier)
    }
}

