//
//  AppDelegate.swift
//  testapp
//
//  Created by Ryan Paglinawan on 5/16/19.
//  Copyright © 2019 Ryan Paglinawan. All rights reserved.
//

import UIKit
import VimeoNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let authController = AuthenticationController(client: VimeoClient.defaultClient, appConfiguration: AppConfiguration.defaultConfiguration, configureSessionManagerBlock: nil)
        
        let loadedAccount: VIMAccount?
        
        do {
            loadedAccount = try authController.loadUserAccount()
        } catch let error {
            loadedAccount = nil
            print("error loading account \(error)")
        }
        
        if loadedAccount == nil {
            authController.clientCredentialsGrant { result in
                
                switch result
                {
                case .success(let account):
                    print("authenticated successfully: \(account)")
                case .failure(let error):
                    print("failure authenticating: \(error)")
                }
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }


}


extension AppConfiguration {
    static let defaultConfiguration = AppConfiguration(clientIdentifier: "1dbea5d4e169e267b6c775b519fcb7bb2f63113b", clientSecret: "7eQp+pIPbJyNQZZGp5jry3FCrkE66RPl/NHm63yhQ7byZKhRdc0+ktnEUtcSHaIWPWl7ddjA7JwHT0fpi146vwfNgcebcAotJoiSQiHSzGNjcOuYqotrWKSS0VI5CHFY", scopes: [.Public], keychainService: "")
}

extension VimeoClient {
    static let defaultClient = VimeoClient(appConfiguration: AppConfiguration.defaultConfiguration, configureSessionManagerBlock: nil)
}
