//
//  TraktSeason.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public typealias TraktSeasonNumber = UInt
public class TraktSeason: TraktObject {
    public let number: TraktSeasonNumber
    public var episodes: [TraktEpisode] = []

    public required init?(data: JSONHash!) {
        guard let number = data?["number"] as? TraktSeasonNumber else {
            return nil
        }
        self.number = number
        super.init(data: data)
    }

    public override func digest(data: JSONHash?) {
        super.digest(data)

        if let episodes = data?["episodes"] as? [JSONHash] {
            self.episodes = episodes.flatMap {
                TraktEpisode(data: $0)
            }.sort {
                $0.number < $1.number
            }
        }
    }

    public var notCompleted: [Watchable] {
        return episodes.filter {$0.watched == false}
    }

    public func episode(number: TraktEpisodeNumber) -> TraktEpisode? {
        return episodes.filter {$0.number == number} . first
    }
}
