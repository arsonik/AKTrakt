//
//  TraktImageSize.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

enum TraktImageSize:String, CustomStringConvertible {
    case Full = "full"
    , Medium = "medium"
    , Thumb = "thumb"
    var description:String {
        return "TraktImageSize:\(rawValue)"
    }
}