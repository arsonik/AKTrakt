//
//  TraktShow.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktShow: TraktObject, Descriptable {
    /// Production year
    public var year: UInt?

    /// Descriptable conformance
    public var title: String?
    public var overview: String?

    public var seasons: [TraktSeason] = []

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

    public var notCompleted: [Watchable] {
        let episodes: [TraktEpisode] = seasons.flatMap({
            $0.notCompleted as? TraktEpisode
        })
        return episodes.sort({
            $0.0.seasonNumber < $0.1.seasonNumber && $0.0.number < $0.1.number
        })
    }

    public func season(number: UInt) -> TraktSeason? {
        return seasons.filter {$0.number == number} . first
    }

    public var nextEpisode: TraktEpisode?

    public override var description: String {
        return "TraktShow(\(title))"
    }
}
