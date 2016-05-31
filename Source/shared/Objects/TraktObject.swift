//
//  TraktObject.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Trakt identifier type
public typealias TraktIdentifier = UInt

/// Equatable conformance
public func == (lhs: TraktObject, rhs: TraktObject) -> Bool {
    return lhs.id == rhs.id && lhs.id != 0 && rhs.id != 0
}

/// Descriptable protocol
public protocol Descriptable {
    var title: String? { get set }
    var overview: String? { get set }
}

/// Watchable protocol
public protocol Watchable {
    var watched: Bool { get set }
    var watchlist: Bool { get set }
    var lastWatchedAt: NSDate? { get set }
    var plays: UInt? { get set }
}

/// Collectable protocol
public protocol Collectable {
    var collectedAt: NSDate? { get set }
}

public class TraktObject: CustomStringConvertible, Hashable {
    /// Object identifiers
    public var ids: [TraktId: AnyObject] = [:] {
        didSet {
            id = ids[TraktId.Trakt] as? TraktIdentifier ?? id
        }
    }

    /// Object trakt.tv identifier
    public var id: TraktIdentifier = 0

    /// Hashable conformance
    public var hashValue: Int {
        return Int(id)
    }

    /// Images's URL by type and size
    public var images: [TraktImageType: [TraktImageSize: NSURL]] = [:]

    public required init?(data: JSONHash!) {
        digest(data)
    }

    /// Digest data
    public func digest(data: JSONHash?) {
        ids = TraktId.extractIds(data) ?? ids

        (data?["images"] as? JSONHash)?.forEach { rawType, list in
            if let type = TraktImageType(rawValue: rawType), listed = list as? JSONHash {
                listed.forEach { rawSize, uri in
                    if let size = TraktImageSize(rawValue: rawSize), u = uri as? String, url = NSURL(string: u) {
                        if images[type] == nil {
                            images[type] = [:]
                        }
                        images[type]?[size] = url
                    }
                }
            }
        }
    }

    /// Retrieve an image url that fits a given imageview
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
        guard let aSize = selectedSize, url = images[type]?[aSize] else {
            return nil
        }
        return url
    }

    /// CustomStringConvertible conformance
    public var description: String {
        return "TraktObject \(ids)"
    }
}
