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

    public let number: Int
    public var seasonNumber: Int?
    public var loaded: Bool? = false
    public var firstAired: NSDate?

    required public init?(data: JSONHash!) {
        guard let en = data?["number"] as? Int else {
            return nil
        }

        number = en
        seasonNumber = data?["season"] as? Int
        super.init(data: data)
    }

    override public func digest(data: JSONHash!) {
        super.digest(data)

        if let fa = data["first_aired"] as? String, date = Trakt.datetimeFormatter.dateFromString(fa) {
            firstAired = date
        }
    }

    public override var description: String {
        return "TraktEpisode id\(id) \(season?.title) \(seasonNumber):\(number)) completed \(watched)"
    }
}
