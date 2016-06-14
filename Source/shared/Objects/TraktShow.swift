//
//  TraktShow.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents a tv show
public class TraktShow: TraktObject, Descriptable, Trending, Watchlist, Credits, Searchable, Recommandable {
    /// Production year
    public var year: UInt?
    /// Descriptable conformance
    public var title: String?
    /// Descriptable conformance
    public var overview: String?
    /// Seasons
    public var seasons: [TraktSeason] = []
    /// Watchlist conformance
    public var watchlist: Bool?

    /**
     Digest data

     - parameter data: data
     */
    override public func digest(_ data: JSONHash?) {
        super.digest(data)

        year = data?["year"] as? UInt ?? year

        if let sdata = data?["seasons"] as? [JSONHash] {
            seasons = sdata.flatMap {
                TraktSeason(data: $0)
            }
        }
    }

    /// list of non watched episodes
    public var notCompleted: [TraktEpisode] {
        return seasons.flatMap {
            $0.notCompleted.flatMap { $0 }
        }
    }

    /**
     Return a season byt its number
     - parameter number: season number
     - returns: seasons
     */
    public func season(_ number: TraktSeasonNumber) -> TraktSeason? {
        return seasons.filter {$0.number == number} . first
    }

    /// next episode to watch
    public var nextEpisode: TraktEpisode? {
        return notCompleted.first
    }

    public static var listName: String {
        return "shows"
    }

    public static var objectName: String {
        return "show"
    }

    /// CustomStringConvertible conformance
    public override var description: String {
        return "TraktShow(\(title))"
    }

    public func extend(_ with: TraktShow) {
        super.extend(with)

        year = with.year ?? year
    }
}
