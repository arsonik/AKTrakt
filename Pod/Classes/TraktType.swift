//
//  TraktType.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public enum TraktType:String {
    case Movies = "movies"
    , Shows = "shows"
    , Seasons = "seasons"
    , Episodes = "episodes"
    , Persons = "person"

    init?(single:String){
        switch single {
        case "movie":	self = .Movies
        case "show":	self = .Shows
        case "season":	self = .Seasons
        case "episode":	self = .Episodes
        case "people":	self = .Persons
        default:
            return nil
        }
    }

    var single:String {
        switch self {
        case .Movies:	return "movie"
        case .Shows:	return "show"
        case .Seasons:	return "season"
        case .Episodes:	return "episode"
        case .Persons:	return "people"
        }
    }
}