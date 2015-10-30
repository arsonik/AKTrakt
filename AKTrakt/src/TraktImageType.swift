//
//  TraktImageType.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

enum TraktImageType:String, CustomStringConvertible {
    case Banner = "banner"
    , ClearArt = "clearart"
    , FanArt = "fanart"
    , HeadShot = "headshot"
    , Logo = "logo"
    , Poster = "poster"
    , Thumb = "thumb"
    , Avatar = "avatar"
    , Screenshot = "screenshot"
    var description:String {
        return "TraktImageType:\(rawValue)"
    }
}