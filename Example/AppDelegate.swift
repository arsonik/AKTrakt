//
//  AppDelegate.swift
//  AKTrakt
//
//  Created by Florian Morello on 10/30/2015.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import UIKit
import AKTrakt

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}

/// Extends Trakt to create an autoload
extension Trakt {
    static private var loaded: Trakt?

    static func autoload() -> Trakt {
        if Trakt.loaded == nil {
            Trakt.loaded = Trakt(clientId: "37558e63c821f673801c2c0788f4f877f5ed626bf5ba4493626173b3ac19b594",
                                 clientSecret: "9a80ed5b84182af99be0a452696e68e525b2c629e6f2a9a7cd748e4147d85690",
                                 applicationId: 3695)
        }
        return Trakt.loaded!
    }
}
