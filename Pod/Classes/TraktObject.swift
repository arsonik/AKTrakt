//
//  TraktObject.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

typealias TraktIdentifier = Int

public class TraktObject : CustomStringConvertible {
	
	var ids:[TraktId:AnyObject]!
	var id:TraktIdentifier? {
		return ids[TraktId.Trakt] as? TraktIdentifier
	}
	var type:TraktType? {
		if self is TraktEpisode {
			return TraktType.Episodes
		}
		else if self is TraktSeason {
			return TraktType.Seasons
		}
		else if self is TraktShow {
			return TraktType.Shows
		}
		else if self is TraktMovie {
			return TraktType.Movies
		}
		return nil
	}
	
	var images:[TraktImageType:[TraktImageSize:String]] = [:]


	init?(data: [String : AnyObject]!) {

		ids = TraktId.extractIds(data) ?? [:]

		if let im = data?["images"] as? [String:AnyObject] {
			for (rawType, list) in im {
				if let type = TraktImageType(rawValue: rawType), listed = list as? [String: AnyObject]  {
					for (rawSize, uri) in listed {
						if let size = TraktImageSize(rawValue: rawSize), u = uri as? String  {
							if images[type] == nil {
								images[type] = [:]
							}
							images[type]![size] = u
						}
					}
				}
			}
		}
	}

	static func autoload(item:[String:AnyObject]!) -> TraktObject! {
		if let it = item?["type"] as? String, type = TraktType(single: it), data = item[type.single] as? [String:AnyObject] {
			switch type {
			case .Shows:
				return TraktShow(data: data)
			case .Movies:
				return TraktMovie(data: data)
			case .Seasons:
                return TraktSeason(data: data)
            case .Episodes:
                return TraktEpisode(data: data)
            case .Persons:
                return TraktPerson(data: data)
			}
		}
		
		return nil
	}
	
	func imageURL(type:TraktImageType, size: TraktImageSize) -> NSURL? {
		if let uri = images[type]?[size] {
			return NSURL(string: uri)
		}
		return nil
	}
	
	var description:String {
		return "TraktObject id:\(id)"
	}
}