//
//  TraktMovie.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktMovie: TraktWatchable {

	public let trailer: String? // Youtube video name ex: _1MDrwqjeGo
    public let rating: Float? // 6.544
    public let year: Int? // 2015
    public let release: NSDate?
    public let runtime: Int? // length
    public let genres: [String]?

    public var crew: [TraktCrew]?
    public var casting: [TraktCharacter]?

	public override init?(data: [String : AnyObject]!) {
		rating = data?["rating"] as? Float
		year = data?["year"] as? Int
        genres = data?["genres"] as? [String]
        runtime = data?["runtime"] as? Int
        let df = NSDateFormatter()
        df.dateFormat = "yyyy'-'MM'-'dd"

        if let r = data?["released"] as? String, d = df.dateFromString(r) {
            release = d
        } else {
            release = nil
        }

		if let x = data?["trailer"] as? String, url = NSURL(string: x), params = url.query?.componentsSeparatedByString("v=") where params.count == 2 {
			trailer = params[1]
		}
		else {
			trailer = nil
		}

		super.init(data: data)
	}
}