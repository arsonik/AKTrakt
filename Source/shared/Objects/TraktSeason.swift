//
//  TraktSeason.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public struct TraktSeason {
    public let number: UInt
    public var episodes: [TraktEpisode] = []

    public init(number: UInt) {
        self.number = number
    }

    public var notCompleted: [TraktEpisode] {
        return episodes.filter {$0.watched == false}
    }

    public func episode(number: UInt) -> TraktEpisode? {
        return episodes.filter {$0.number == number} . first
    }
}
