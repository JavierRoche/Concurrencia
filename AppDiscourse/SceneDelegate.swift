//
//  SceneDelegate.swift
//  AppDiscourse
//
//  Created by APPLE on 31/03/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: Jerarquia de Vista
    // UIWindow -> UITabBarController -> (UINavigationController's) -> UIViewController's
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Creamos ViewController para cada tab de la app
        let topicsViewController: TopicsViewController = TopicsViewController()
        let categoriesViewController: CategoriesViewController = CategoriesViewController()
        let usersViewController: UsersViewController = UsersViewController()
        // Con la propiedad tabBarItem podemos fijar detalles de cada tab
        topicsViewController.tabBarItem = UITabBarItem.init(title: "Topics", image: UIImage(systemName: "list.dash"), tag: 0)
        categoriesViewController.tabBarItem = UITabBarItem.init(title: "Categories", image: UIImage(systemName: "folder.fill"), tag: 1)
        usersViewController.tabBarItem = UITabBarItem.init(title: "Users", image: UIImage.init(systemName: "person.3.fill"), tag: 2)
        //Creamos los navigation para cada vista que queramos que tenga navegacion y titulo
        let categoriesNavigationViewController = UINavigationController.init(rootViewController: categoriesViewController)
        // Creamos la tabBar y la configuramos con los ViewController
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [topicsViewController, categoriesNavigationViewController, usersViewController]
        tabBarController.tabBar.barStyle = .default
        
        // Al iniciarse la aplicacion, la ventana carga un controlador de vista en ella (rootViewController) que sera el tabBar
        guard let windowScene = (scene as? UIWindowScene) else { return }
        //Instanciamos la ventana usando el inicializador frame que le damos mediante el CGRect de nuestra windowScene
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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

