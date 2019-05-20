//
//  VimeoHandler.swift
//  testapp
//
//  Created by Ryan Paglinawan on 5/16/19.
//  Copyright © 2019 Ryan Paglinawan. All rights reserved.
//

import Foundation
import VimeoNetworking
import PlayerKit
import UIKit

//Where we are going to call to get data
let BASE_URL : String = "https://vimeo.com/fitplan"

protocol VimeoHandler {
//    Add basic controls
    var appConfig : AppConfiguration { get }
}

class VimeoDelegate : VimeoHandler {
    
    let _client : VimeoClient
    var _account : VIMAccount?
    
    let appConfig: AppConfiguration
    
    var vVideo : [VIMVideo] = [] {
        didSet {
            print("value added")
            print("values in: \(vVideo)")
        }
    }
    
//    this is more important init
    init(clientID: String, clientSecret: String, scopes: [Scope], keychainServices: String, baseURL: URL, additional: [String: Any]) {
        appConfig = AppConfiguration(clientIdentifier: clientID, clientSecret: clientSecret, scopes: scopes, keychainService: keychainServices)
        
        _client = VimeoClient(appConfiguration: appConfig, sessionManager: nil)
        print("\(baseURL.absoluteString)")
        
        let authController = AuthenticationController(client: _client, appConfiguration: appConfig, configureSessionManagerBlock: nil)
        
        authController.accessToken(token: additional["Token"] as! String, completion: { auth in
            switch auth {
            case .success(let account):
                print("auth success \(account.isAuthenticated())\n auth with cred:\(account.isAuthenticatedWithClientCredentials())\n auth with user:\(account.isAuthenticatedWithUser())")
                print(account.user?.bio ?? "NoBio")
                
                self._account = account
            case .failure(let error):
                print(error)
            }
        })
    }
}
// Error codes that should atleast catch any issues during execution of app
enum VimeoError : Error {
    case NullURL
    case NullConnection
    case unknown
}
