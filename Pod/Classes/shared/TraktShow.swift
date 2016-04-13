//
//  TraktShow.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktShow: TraktWatchable {

	private var _seasons: [TraktSeason] = []
	public var seasons: [TraktSeason] {
		return _seasons
	}
	
	public var crew: [TraktCrew]?
	public var casting: [TraktCharacter]?

	public var notCompleted: [TraktEpisode] {
		return seasons.flatMap({ $0.notCompleted })
	}

	public override var description: String {
		return "TraktShow(\(title))"
	}

	public func addSeason(season: TraktSeason) {
		season.show = self
		_seasons.append(season)
	}

    public var nextEpisode: TraktEpisode?
}
