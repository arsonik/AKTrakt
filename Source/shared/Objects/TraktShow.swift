//
//  TraktShow.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents a tv show
public class TraktShow: TraktObject, Descriptable, Trending, Watchlist, Credits {
    /// Production year
    public var year: UInt?
    /// Descriptable conformance
    public var title: String?
    /// Descriptable conformance
    public var overview: String?
    /// Seasons
    public var seasons: [TraktSeason] = []

    /**
     Digest data

     - parameter data: data
     */
    override public func digest(data: JSONHash?) {
        super.digest(data)

        year = data?["year"] as? UInt ?? year

        if let sdata = data?["seasons"] as? [JSONHash] {
            seasons = sdata.flatMap {
                TraktSeason(data: $0)
            }
        }

        title = data?["title"] as? String ?? title
        overview = data?["overview"] as? String ?? overview
    }

    /// list of non watched episodes
    public var notCompleted: [TraktEpisode] {
        let episodes: [TraktEpisode] = seasons.flatMap {
            $0.notCompleted.flatMap { $0 }
        }
        return episodes.sort({
            $0.0.seasonNumber < $0.1.seasonNumber && $0.0.number < $0.1.number
        })
    }

    /**
     Return a season byt its number
     - parameter number: season number
     - returns: seasons
     */
    public func season(number: TraktSeasonNumber) -> TraktSeason? {
        return seasons.filter {$0.number == number} . first
    }

    /// next episode to watch
    public var nextEpisode: TraktEpisode?

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

    public func extend(with: TraktShow) {
        super.extend(with)

        year = with.year ?? year
    }
}
