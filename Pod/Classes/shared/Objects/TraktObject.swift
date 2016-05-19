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
    return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id && lhs.id != 0 && rhs.id != 0
}

public class TraktObject: CustomStringConvertible, Hashable {

	public var ids: [TraktId: AnyObject] = [:]
    
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
        return id ?? 0
    }

	public var images: [TraktImageType: [TraktImageSize: String]] = [:]

	public init?(data: JSONHash!) {
		digest(data)
	}

	public func digest(data: JSONHash?) {
		ids = TraktId.extractIds(data) ?? [:]

		(data?["images"] as? JSONHash)?.forEach { rawType, list in
			if let type = TraktImageType(rawValue: rawType), listed = list as? JSONHash {
				listed.forEach { rawSize, uri in
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

	static func autoload(item: JSONHash!) -> TraktObject! {
		guard let it = item?["type"] as? String, type = TraktType(single: it), data = item[type.single] as? JSONHash else {
            return nil
        }
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

    public func imageURL(type: TraktImageType, thatFits imageView: UIImageView?) -> NSURL? {
		guard let image = imageView,
			// sort by area ascending
			sizes = TraktImageType.sizes[type]?.sort({$0.0.1.area < $0.1.1.area}) else {
            return nil
        }
		let area = (image.frame.width * image.frame.height) * UIScreen.mainScreen().scale
		var selectedSize: TraktImageSize! = nil
		for size in sizes {
			if size.1.area >= area {
				selectedSize = size.0
				//print("Filling with \(size.0.rawValue) \(size.1) > \(image.frame.size)")
				break
			}
		}
		if selectedSize == nil {
			// use the largest image
			selectedSize = sizes.last?.0
		}
		guard let aSize = selectedSize, uri = images[type]?[aSize] else {
			return nil
		}
		return NSURL(string: uri)
    }

	public var description: String {
		return "TraktObject \(ids)"
	}
}
