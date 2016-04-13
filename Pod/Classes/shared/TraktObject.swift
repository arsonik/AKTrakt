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

		(data?["images"] as? [String: AnyObject])?.forEach { rawType, list in
            if let type = TraktImageType(rawValue: rawType), listed = list as? [String: AnyObject] {
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

	static func autoload(item: [String: AnyObject]!) -> TraktObject! {
		guard let it = item?["type"] as? String, type = TraktType(single: it), data = item[type.single] as? [String: AnyObject] else {
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
        guard let image = imageView else {
            return nil
        }
        let scale = UIScreen.mainScreen().scale
        let area = (image.frame.width * image.frame.height) * scale
        let sizes = TraktImageType.sizes[type]?.sort({$0.0.1.area < $0.1.1.area})
        print(sizes)
        return nil
    }


	@available(*, deprecated=1.0, message="Use imageURL ! that fits") public func imageURL(type: TraktImageType, size: TraktImageSize) -> NSURL? {
		guard let uri = images[type]?[size] else {
            return nil
        }
        return NSURL(string: uri)
	}

	public var description: String {
		return "TraktObject id:\(id)"
	}
}
extension CGSize {
    var area: CGFloat {
        return width * height
    }
}