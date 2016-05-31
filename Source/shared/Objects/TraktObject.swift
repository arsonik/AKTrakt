//
//  TraktObject.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public typealias TraktIdentifier = UInt

public func == (lhs: TraktObject, rhs: TraktObject) -> Bool {
    return lhs.id == rhs.id && lhs.id != 0 && rhs.id != 0
}

public protocol Castable {
    var crew: [TraktCrew]? { get set }
    var casting: [TraktCharacter]? { get set }
}

public protocol Descriptable {
    var title: String? { get set }
    var overview: String? { get set }
}

public protocol Watchable {
    var watched: Bool { get set }
    var watchlist: Bool { get set }
    var lastWatchedAt: NSDate? { get set }
    var plays: UInt? { get set }
}

public protocol Collectable {
    var collectedAt: NSDate? { get set }
}

public class TraktObject: CustomStringConvertible, Hashable {
    public var ids: [TraktId: AnyObject] = [:] {
        didSet {
            id = ids[TraktId.Trakt] as? TraktIdentifier ?? 0
        }
    }

    public var id: TraktIdentifier = 0

    public var hashValue: Int {
        return Int(id)
    }

    public var images: [TraktImageType: [TraktImageSize: String]] = [:]

    public required init?(data: JSONHash!) {
        digest(data)
    }

    public func digest(data: JSONHash?) {
        ids = TraktId.extractIds(data) ?? ids

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
