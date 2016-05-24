//
//  TraktId.swift
//  Arsonik
//
//  Created by Florian Morello on 10/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public enum TraktId: String {
	case Imdb = "imdb"
	case Slug = "slug"
	case Tmdb = "tmdb"
	case Trakt = "trakt"
	case Tvdb = "tvdb"
	case Tvrage = "tvrage"

    static func extractIds(data: JSONHash!) -> [TraktId: AnyObject]! {
        var ids: [TraktId: AnyObject] = [:]
		(data?["ids"] as? JSONHash)?.forEach { id, value in
            if let identifier = TraktId(rawValue: id) {
                ids[identifier] = value
            }
		}
        return ids.count > 0 ? ids : nil
	}
}
