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
public class TraktEpisode: TraktObject, Descriptable, Watchable, Collectable, Watchlist, Searchable {
    /// Episode's number
    public let number: TraktEpisodeNumber
    /// Episode's season number
    public var seasonNumber: TraktSeasonNumber?
    /// Episode's first aired date
    public var firstAired: Date?
    /// Descriptable conformance
    public var title: String?
    /// Descriptable conformance
    public var overview: String?
    /// Watchable conformance
    public var watched: Bool?
    /// Watchlist conformance
    public var watchlist: Bool?
    /// Watchable conformance
    public var lastWatchedAt: Date?
    /// Watchable conformance
    public var plays: UInt?
    /// Collectable conformance
    public var collectedAt: Date?

    /**
     Init with data

     - parameter data: data
     */
    required public init?(data: JSONHash!) {
        guard let en = data?["number"] as? TraktEpisodeNumber else {
            return nil
        }

        number = en
        super.init(data: data)
    }

    /**
     Digest data

     - parameter data: data
     */
    override public func digest(_ data: JSONHash!) {
        super.digest(data)

        seasonNumber = data?["season"] as? TraktSeasonNumber ?? seasonNumber
        if let fa = data["first_aired"] as? String, let date = Trakt.datetimeFormatter.date(from: fa) {
            firstAired = date
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

    /**
     Extend an episode with another

     - parameter with: TraktEpisode
     */
    public func extend(_ with: TraktEpisode) {
        super.extend(with)

        firstAired = with.firstAired ?? firstAired
        seasonNumber = with.seasonNumber ?? seasonNumber
    }
}
