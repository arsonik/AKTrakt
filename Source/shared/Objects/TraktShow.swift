//
//  TraktShow.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktShow: TraktObject, Descriptable, Castable {
    public var seasons: [TraktSeason] = []
    public var crew: [TraktCrew]?
    public var casting: [TraktCharacter]?
    /// Production year
    public var year: UInt?

    /// Descriptable conformance
    public var title: String?
    public var overview: String?

    public var type: TraktType {
        return .Shows
    }

    override public func digest(data: JSONHash?) {
        super.digest(data)

        year = data?["year"] as? UInt ?? year

        if let sdata = data?["seasons"] as? [JSONHash] {
            seasons = sdata.flatMap {
                guard let number = $0["number"] as? UInt else {
                    return nil
                }
                return TraktSeason(number: number)
            }
        }

        title = data?["title"] as? String ?? title
        overview = data?["overview"] as? String ?? overview
    }

    public var notCompleted: [TraktEpisode] {
        return seasons.flatMap { $0.notCompleted }.sort {$0.0.seasonNumber < $0.1.seasonNumber && $0.0.number < $0.1.number}
    }

    public func season(number: UInt) -> TraktSeason? {
        return seasons.filter {$0.number == number} . first
    }

    public var nextEpisode: TraktEpisode?

    public override var description: String {
        return "TraktShow(\(title))"
    }
}
