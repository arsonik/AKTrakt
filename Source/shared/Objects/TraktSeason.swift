//
//  TraktSeason.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Season number alias
public typealias TraktSeasonNumber = UInt

/// Represents a tv show season
public class TraktSeason: TraktObject, Watchlist {
    /// Season number
    public let number: TraktSeasonNumber
    /// Season episodes
    public var episodes: [TraktEpisode] = []
    /// Watchlist conformance
    public var watchlist: Bool?

    /**
     Init with data

     - parameter data: data
     */
    public required init?(data: JSONHash!) {
        guard let number = data?["number"] as? TraktSeasonNumber else {
            return nil
        }
        self.number = number
        super.init(data: data)
    }

    /**
     Digest data

     - parameter data: data
     */
    public override func digest(_ data: JSONHash?) {
        super.digest(data)

        if let episodes = data?["episodes"] as? [JSONHash] {
            self.episodes = episodes.flatMap {
                guard let episode = TraktEpisode(data: $0) else {
                    return nil
                }
                episode.seasonNumber = number ?? episode.seasonNumber
                return episode
            }.sorted {
                $0.number < $1.number
            }
        }
    }

    /// Get not watched episodes
    public var notCompleted: [TraktEpisode] {
        return episodes.filter { $0.watched == false }
    }

    /**
     Get an episode by its number
     - parameter number: Episode number
     - returns: episode array
     */
    public func episode(_ number: TraktEpisodeNumber) -> TraktEpisode? {
        return episodes.filter {$0.number == number} . first
    }

    public static var listName: String {
        return "seasons"
    }

    public static var objectName: String {
        return "season"
    }

    override public var description: String {
        return "\(super.description) season:\(number) episodesCount:\(episodes.count)"
    }
}
