//
//  TraktCrewPosition.swift
//  Pods
//
//  Created by Florian Morello on 01/06/16.
//
//

import Foundation

/**
 Represent a crew position

 - Production:    Production description
 - Art:           Art description
 - Crew:          Crew description
 - CostumeMakeUp: CostumeMakeUp description
 - Directing:     Directing description
 - Writing:       Writing description
 - Sound:         Sound description
 - Camera:        Camera description
 */
public enum TraktCrewPosition: String {
    case Production = "production"
    case Art = "art"
    case Crew = "crew"
    case CostumeMakeUp = "costume & make-up"
    case Directing = "directing"
    case Writing = "writing"
    case Sound = "sound"
    case Camera = "camera"
}
