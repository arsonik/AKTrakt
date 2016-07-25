//
//  TraktObject.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import UIKit

/// Trakt identifier alias
public typealias TraktIdentifier = UInt

/**
 Compare two TraktObject by their ids
 - parameter lhs: first object
 - parameter rhs: second object
 - returns: Are they true
 */
public func == (lhs: TraktObject, rhs: TraktObject) -> Bool {
    return lhs.id == rhs.id && lhs.id != 0 && rhs.id != 0
}

/// Descriptable protocol
public protocol Descriptable {
    /// object title
    var title: String? { get set }
    /// object overview
    var overview: String? { get set }
}

/// Watchable protocol
public protocol Watchable {
    /// boolean indicating if the object has been watched
    var watched: Bool? { get set }
    /// date of the last play
    var lastWatchedAt: Date? { get set }
    /// number of times this object has been played
    var plays: UInt? { get set }
}

/// Collectable protocol
public protocol Collectable {
    /// date added to collection
    var collectedAt: Date? { get set }
}

public protocol Extendable {
    associatedtype T
    func extend(_ with: T)
}

/// TraktObject (abstract) class
public class TraktObject: CustomStringConvertible, Hashable, Extendable {
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
    public var images: [TraktImageType: [TraktImageSize: URL]] = [:]

    /**
     Init object with data
     - parameter data: JSONHash
     */
    public required init?(data: JSONHash!) {
        digest(data)
    }

    /**
     Digest the data passed
     - parameter data: String: Value Dictionary
     */
    public func digest(_ data: JSONHash?) {
        ids = TraktId.extractIds(data) ?? ids

        (data?["images"] as? JSONHash)?.forEach { rawType, list in
            if let type = TraktImageType(rawValue: rawType), let listed = list as? JSONHash {
                listed.forEach { rawSize, uri in
                    if let size = TraktImageSize(rawValue: rawSize), let u = uri as? String, let url = URL(string: u) {
                        if images[type] == nil {
                            images[type] = [:]
                        }
                        images[type]?[size] = url
                    }
                }
            }
        }

        if var me = self as? Descriptable {
            me.title = data?["title"] as? String ?? me.title
            me.overview = data?["overview"] as? String ?? me.overview
        }

        if var me = self as? Watchable {
            me.watched = data?["completed"] as? Bool ?? me.watched
            me.plays = data?["plays"] as? UInt ?? me.plays
            if let fa = data?["last_watched_at"] as? String, let date = Trakt.datetimeFormatter.date(from: fa) {
                me.lastWatchedAt = date
                me.watched = true
            }
        }

        if var me = self as? Collectable {
            if let string = data?["collected_at"] as? String, let date = Trakt.datetimeFormatter.date(from: string) {
                me.collectedAt = date
            }
        }
    }

    /**
     Retrieve an image url that fits a given UIImageview base on its (retina) size
     - parameter type: the image type requested
     - parameter thatFits: the image view to be filled
     - returns: An optional NSURL
     */
    public func imageURL(_ type: TraktImageType, thatFits image: UIImageView) -> URL? {
        let sizes = type.sizes.sorted(isOrderedBefore: {$0.0.1.area < $0.1.1.area})
        let area = (image.frame.width * image.frame.height) * UIScreen.main().scale
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
        guard let aSize = selectedSize, let url = images[type]?[aSize] else {
            return nil
        }
        return url
    }

    /// CustomStringConvertible conformance
    public var description: String {
        return "\(self.dynamicType) ids:\(ids)"
    }

    /**
     Allow to extend an object with another one
     Useful when you retrieve data fron multiple request but you want to keep reference to one object

     - parameter with: Object of the same type
     */
    public func extend(_ with: TraktObject) {
        ids = with.ids ?? ids
        images = with.images ?? images

        if var me = self as? Descriptable, let him = with as? Descriptable {
            me.title = him.title ?? me.title
            me.overview = him.overview ?? me.overview
        }
        if var me = self as? Watchable, let him = with as? Watchable {
            me.watched = him.watched ?? me.watched
            me.lastWatchedAt = him.lastWatchedAt ?? me.lastWatchedAt
            me.plays = him.plays ?? me.plays
        }
        if var me = self as? Watchlist, let him = with as? Watchlist {
            me.watchlist = him.watchlist ?? me.watchlist
        }
        if var me = self as? Collectable, let him = with as? Collectable {
            me.collectedAt = him.collectedAt ?? me.collectedAt
        }
    }
}
