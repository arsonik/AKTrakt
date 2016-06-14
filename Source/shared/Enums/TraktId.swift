//
//  TraktId.swift
//  Arsonik
//
//  Created by Florian Morello on 10/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents an object identifier
public enum TraktId: String {
    /// Imdb identifier
    case Imdb = "imdb"
    /// Slug identifier (trakt)
    case Slug = "slug"
    /// Tmdb identifier
    case Tmdb = "tmdb"
    /// Trakt identifier
    case Trakt = "trakt"
    /// Tvdb identifier
    case Tvdb = "tvdb"
    /// Tvrage identifier
    case Tvrage = "tvrage"

    /**
     Extract identifiers: value from trakt data

     - parameter data: JSONHash

     - returns: parsed key:value
     */
    static func extractIds(_ data: JSONHash?) -> [TraktId: AnyObject]? {
        var ids: [TraktId: AnyObject] = [:]
        (data?["ids"] as? JSONHash)?.forEach { id, value in
            if let identifier = TraktId(rawValue: id) {
                ids[identifier] = value
            }
        }
        return ids.count > 0 ? ids : nil
    }
}
