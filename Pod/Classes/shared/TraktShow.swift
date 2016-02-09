//
//  TraktShow.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktShow : TraktWatchable {
	
	public var seasons:[TraktSeason] = []
	
	public var notCompleted:[TraktEpisode] {
		var list:[TraktEpisode] = []
		for season in seasons {
			list += season.notCompleted
		}
		return list
	}
	
	public override var description:String {
		return "TraktShow(\(title))"
	}
    
    public override init?(data: [String : AnyObject]!) {
        super.init(data: data)
    }
}

