//
//  TraktType.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public enum TraktType: String {
    case Movies = "movies"
    case Shows = "shows"
    case Seasons = "seasons"
    case Episodes = "episodes"
    case Persons = "person"

    public static let singularMap: [String: TraktType] = [
        "movie": .Movies,
        "show":	.Shows,
        "season": .Seasons,
        "episode": .Episodes,
        "people": .Persons
    ]

    public init?(single: String) {
        guard let type = TraktType.singularMap[single] else {
            return nil
        }
        self = type
    }

    public var single: String {
        return TraktType.singularMap.filter({ $0.1 == self }).first!.0
    }
}
