//
//  TraktShow.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

class TraktShow : TraktWatchable {
	
	var seasons:[TraktSeason] = []
	
	var notCompleted:[TraktEpisode] {
		var list:[TraktEpisode] = []
		for season in seasons {
			list += season.notCompleted
		}
		return list
	}
	
	override var description:String {
		return "TraktShow(\(title))"
	}
}

