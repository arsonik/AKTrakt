//
//  TraktObject.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public typealias TraktIdentifier = Int

public func == (lhs: TraktObject, rhs: TraktObject) -> Bool {
    return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
}

public class TraktObject: CustomStringConvertible, Hashable {

	public var ids: [TraktId: AnyObject]!
	public var id: TraktIdentifier! {
		return ids[TraktId.Trakt] as? TraktIdentifier
	}
	public var type: TraktType? {
		if self is TraktEpisode {
			return .Episodes
		} else if self is TraktSeason {
			return .Seasons
		} else if self is TraktShow {
			return .Shows
		} else if self is TraktMovie {
			return .Movies
		}
		return nil
	}

    public var hashValue: Int {
        return id!
    }

	public var images: [TraktImageType: [TraktImageSize: String]] = [:]

	init?(data: [String: AnyObject]!) {

		ids = TraktId.extractIds(data) ?? [:]

		if let im = data?["images"] as? [String: AnyObject] {
			for (rawType, list) in im {
				if let type = TraktImageType(rawValue: rawType), listed = list as? [String: AnyObject] {
					for (rawSize, uri) in listed {
						if let size = TraktImageSize(rawValue: rawSize), u = uri as? String {
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

	static func autoload(item: [String: AnyObject]!) -> TraktObject! {
		if let it = item?["type"] as? String, type = TraktType(single: it), data = item[type.single] as? [String: AnyObject] {
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

	public func imageURL(type: TraktImageType, size: TraktImageSize) -> NSURL? {
		if let uri = images[type]?[size] {
			return NSURL(string: uri)
		}
		return nil
	}

	public var description: String {
		return "TraktObject id:\(id)"
	}
}
