//
//  TraktType.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents a trakt object type
public enum TraktType: String {
    /// Movies
    case Movies = "movies"
    /// Shows
    case Shows = "shows"
    /// Seasons
    case Seasons = "seasons"
    /// Episodes
    case Episodes = "episodes"
    /// Persons
    case Persons = "person"

    /// Singular values foreach type
    static let singularMap: [String: TraktType] = [
        "movie": .Movies,
        "show":	.Shows,
        "season": .Seasons,
        "episode": .Episodes,
        "people": .Persons
    ]

    /**
     Init with a singular type

     - parameter single: singular type
     */
    public init?(single: String) {
        guard let type = TraktType.singularMap[single] else {
            return nil
        }
        self = type
    }

    /// Get singular string value
    public var single: String {
        return TraktType.singularMap.filter({ $0.1 == self }).first!.0
    }

    /// Associated TraktObject type
    public var classType: TraktObject.Type? {
        switch self {
        case .Movies:
            return TraktMovie.self
        case .Shows:
            return TraktShow.self
        case .Seasons:
            return TraktSeason.self
        case .Persons:
            return TraktPerson.self
        case .Episodes:
            return TraktEpisode.self
        }
    }
}
