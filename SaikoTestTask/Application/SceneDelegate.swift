//
//  SceneDelegate.swift
//  SaikoTestTask
//
//  Created by Вадим Сайко on 30.06.23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let viewController = ViewController()
        window.rootViewController = viewController
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
    }
}
