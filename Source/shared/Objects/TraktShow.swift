//
//  TraktShow.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktShow: TraktWatchable, Castable, TraktIdentifiable {

    private var _seasons: [TraktSeason] = []
    public var seasons: [TraktSeason] {
        return _seasons
    }

    public var crew: [TraktCrew]?
    public var casting: [TraktCharacter]?
    /// Production year
    public var year: Int?

    public var type: TraktType {
        return .Shows
    }

    override public func digest(data: JSONHash?) {
        super.digest(data)

        year = data?["year"] as? Int ?? year
    }

    public var notCompleted: [TraktEpisode] {
        return seasons.flatMap { $0.notCompleted }.sort {$0.0.seasonNumber < $0.1.seasonNumber && $0.0.number < $0.1.number}
    }

    public func season(number: Int) -> TraktSeason? {
        return seasons.filter {$0.number == number} . first
    }

    public func addSeason(season: TraktSeason) {
        season.show = self
        _seasons.append(season)
    }

    public var nextEpisode: TraktEpisode?

    public override var description: String {
        return "TraktShow(\(title))"
    }
}
