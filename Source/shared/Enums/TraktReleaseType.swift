//
//  TraktReleaseType.swift
//  Pods
//
//  Created by Florian Morello on 01/06/16.
//
//

import Foundation

/**
 Release type

 - Unknown:    Unknown description
 - Premiere:   Premiere description
 - Limited:    Limited description
 - Theatrical: Theatrical description
 - Digital:    Digital description
 - Physical:   Physical description
 - Tv:         Tv description
 */
public enum TraktReleaseType: String {
    case Unknown = "unknown"
    case Premiere = "premiere"
    case Limited = "limited"
    case Theatrical = "theatrical"
    case Digital = "digital"
    case Physical = "physical"
    case Tv = "tv"
}
