//
//  TraktSeason.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktSeason: TraktWatchable, TraktIdentifiable {

    public weak var show: TraktShow?

    public let number: Int

    private var _episodes: [TraktEpisode] = []
    public var episodes: [TraktEpisode] {
        return _episodes
    }

    public var type: TraktType {
        return .Seasons
    }

    required public init?(data: JSONHash!) {
        guard let sn = data?["number"] as? Int else {
            return nil
        }

        number = sn
        super.init(data: data)
    }

    override public func digest(data: JSONHash?) {
        super.digest(data)

        if let eps = data?["episodes"] as? [JSONHash] {
            _episodes = eps.flatMap {
                TraktEpisode(data: $0)
            }
        }
    }

    public var notCompleted: [TraktEpisode] {
        return episodes.filter {$0.watched == false}
    }

    public func episode(number: Int) -> TraktEpisode? {
        return episodes.filter {$0.number == number} . first
    }

    public func addEpisode(episode: TraktEpisode) {
        episode.season = self
        _episodes.append(episode)
    }

    public override var description: String {
        return "TraktSeason(\(number)) \(episodes.count-notCompleted.count)/\(episodes.count)"
    }
}
