//
//  TraktImageType.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public enum TraktImageType: String {
    case Banner = "banner"
    case ClearArt = "clearart"
    case FanArt = "fanart"
    case HeadShot = "headshot"
    case Logo = "logo"
    case Poster = "poster"
    case Thumb = "thumb"
    case Avatar = "avatar"
    case Screenshot = "screenshot"


    static var sizes: [TraktImageType: [TraktImageSize: CGSize]] = [
        .Poster: [
            .Full: CGSize(width: 1000, height: 1500),
            .Medium: CGSize(width: 600, height: 900),
            .Thumb: CGSize(width: 300, height: 450),
        ],
        .ClearArt: [
            .Full: CGSize(width: 1920, height: 1080),
            .Medium: CGSize(width: 1280, height: 720),
            .Thumb: CGSize(width: 853, height: 480),
        ],
        .Screenshot: [
            .Full: CGSize(width: 1920, height: 1080),
            .Medium: CGSize(width: 1280, height: 720),
            .Thumb: CGSize(width: 853, height: 480),
        ],
        .HeadShot: [
            .Full: CGSize(width: 1000, height: 1500),
            .Medium: CGSize(width: 600, height: 900),
            .Thumb: CGSize(width: 300, height: 450),
        ],
        .Banner: [
            .Full: CGSize(width: 1000, height: 185),
        ],
        .Logo: [
            .Full: CGSize(width: 800, height: 310),
        ],
        .ClearArt: [
            .Full: CGSize(width: 1000, height: 562),
        ],
        .Thumb: [
            .Full: CGSize(width: 1000, height: 562),
        ],
        .Avatar: [
            .Full: CGSize(width: 256, height: 256),
        ],
    ]
}
