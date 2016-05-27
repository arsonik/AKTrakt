//
//  TraktEpisode.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktEpisode: TraktWatchable {

    public weak var season: TraktSeason?

    public let number: UInt
    public var seasonNumber: UInt?
    public var loaded: Bool? = false
    public var firstAired: NSDate?


    var lastWatchedAt: NSDate? = nil
    var plays: UInt? = nil

    required public init?(data: JSONHash!) {
        guard let en = data?["number"] as? UInt else {
            return nil
        }

        number = en
        seasonNumber = data?["season"] as? UInt
        super.init(data: data)
    }

    override public func digest(data: JSONHash!) {
        super.digest(data)

        if let fa = data["first_aired"] as? String, date = Trakt.datetimeFormatter.dateFromString(fa) {
            firstAired = date
        }
        if let fa = data["last_watched_at"] as? String, date = Trakt.datetimeFormatter.dateFromString(fa) {
            lastWatchedAt = date
        }
        if let pls = data["plays"] as? UInt {
            plays = pls
        }
    }

    public override var description: String {
        return "TraktEpisode id\(id) \(season?.title) \(seasonNumber):\(number)) completed \(watched)"
    }
}
