//
//  TraktSeason.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktSeason: TraktWatchable {

    public weak var show: TraktShow?

    public let number: UInt

    public var episodes: [TraktEpisode] = []

    required public init?(data: JSONHash!) {
        guard let sn = data?["number"] as? UInt else {
            return nil
        }

        number = sn
        super.init(data: data)
    }

    override public func digest(data: JSONHash?) {
        super.digest(data)

        if let eps = data?["episodes"] as? [JSONHash] {
            episodes = eps.flatMap {
                TraktEpisode(data: $0)
            }
        }
    }

    public var notCompleted: [TraktEpisode] {
        return episodes.filter {$0.watched == false}
    }

    public func episode(number: UInt) -> TraktEpisode? {
        return episodes.filter {$0.number == number} . first
    }

    public override var description: String {
        return "TraktSeason(\(number)) \(episodes.count-notCompleted.count)/\(episodes.count)"
    }
}
