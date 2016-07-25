//
//  TraktImageType.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import UIKit

/// Represents the possible image type
public enum TraktImageType: String {
    /// Banner
    case Banner = "banner"
    /// ClearArt
    case ClearArt = "clearart"
    /// FanArt
    case FanArt = "fanart"
    /// HeadShot (person's face)
    case HeadShot = "headshot"
    /// Logo
    case Logo = "logo"
    /// Poster
    case Poster = "poster"
    /// Thumb
    case Thumb = "thumb"
    /// Avatar
    case Avatar = "avatar"
    /// Screenshot
    case Screenshot = "screenshot"

    /// Return available sizes for type
    var sizes: [TraktImageSize: CGSize] {
        switch self {
        case .Poster:
            return [
                .Full: CGSize(width: 1000, height: 1500),
                .Medium: CGSize(width: 600, height: 900),
                .Thumb: CGSize(width: 300, height: 450),
            ]
        case .FanArt:
            return [
                .Full: CGSize(width: 1920, height: 1080),
                .Medium: CGSize(width: 1280, height: 720),
                .Thumb: CGSize(width: 853, height: 480),
            ]
        case .Screenshot:
            return [
                .Full: CGSize(width: 1920, height: 1080),
                .Medium: CGSize(width: 1280, height: 720),
                .Thumb: CGSize(width: 853, height: 480),
            ]
        case .HeadShot:
            return [
                .Full: CGSize(width: 1000, height: 1500),
                .Medium: CGSize(width: 600, height: 900),
                .Thumb: CGSize(width: 300, height: 450),
            ]
        case .Banner:
            return [
                .Full: CGSize(width: 1000, height: 185),
            ]
        case .Logo:
            return [
                .Full: CGSize(width: 800, height: 310),
            ]
        case .ClearArt:
            return [
                .Full: CGSize(width: 1000, height: 562),
            ]
        case .Thumb:
            return [
                .Full: CGSize(width: 1000, height: 562),
            ]
        case .Avatar:
            return [
                .Full: CGSize(width: 256, height: 256),
            ]
        }
    }
}
