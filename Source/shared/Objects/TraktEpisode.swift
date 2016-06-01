//
//  TraktEpisode.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Episode number alias
public typealias TraktEpisodeNumber = UInt

/// Represents a tv show episode
public class TraktEpisode: TraktObject, Descriptable, Watchable, Collectable, Watchlist {
    /// Episode's number
    public let number: TraktEpisodeNumber
    /// Episode's season number
    public var seasonNumber: UInt?
    /// Episode's first aired date
    public var firstAired: NSDate?
    /// Descriptable conformance
    public var title: String?
    /// Descriptable conformance
    public var overview: String?
    /// Watchable conformance
    public var watched: Bool = false
    /// Watchable conformance
    public var watchlist: Bool = false
    /// Watchable conformance
    public var lastWatchedAt: NSDate?
    /// Watchable conformance
    public var plays: UInt?
    /// Collectable conformance
    public var collectedAt: NSDate?

    /**
     Init with data

     - parameter data: data
     */
    required public init?(data: JSONHash!) {
        guard let en = data?["number"] as? UInt else {
            return nil
        }

        number = en
        seasonNumber = data?["season"] as? UInt
        super.init(data: data)
    }

    /**
     Digest data

     - parameter data: data
     */
    override public func digest(data: JSONHash!) {
        super.digest(data)

        if let fa = data["first_aired"] as? String, date = Trakt.datetimeFormatter.dateFromString(fa) {
            firstAired = date
        }

        title = data?["title"] as? String ?? title
        overview = data?["overview"] as? String ?? overview
        watched = data?["completed"] as? Bool ?? watched
        plays = data?["plays"] as? UInt ?? plays
        if let fa = data["last_watched_at"] as? String, date = Trakt.datetimeFormatter.dateFromString(fa) {
            lastWatchedAt = date
        }

        if let string = data?["collected_at"] as? String, date = Trakt.datetimeFormatter.dateFromString(string) {
            collectedAt = date
        }
    }

    /// CustomStringConvertible conformance
    public override var description: String {
        return "TraktEpisode id\(id) \(seasonNumber):\(number)) completed \(watched)"
    }

    public static var listName: String {
        return "episodes"
    }

    public static var objectName: String {
        return "episode"
    }
}
