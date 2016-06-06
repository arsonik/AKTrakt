//
//  Watchlist.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire


public class TraktRequestGetWatchlist<T: TraktObject where T: protocol<Watchlist>>: TraktRequest {
    let type: T.Type
    public init(type: T.Type, extended: TraktRequestExtendedOptions? = nil, sort: TraktSortHeaders? = nil) {
        self.type = type
        super.init(path: "/sync/watchlist/\(type.listName)", oAuth: true, params: extended?.value(), headers: sort?.value())
    }

    public func request(trakt: Trakt, completion: ([(listedAt: NSDate, media: T)]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            completion(entries.flatMap {
                let media: T? = self.type.init(data: $0[self.type.objectName] as? JSONHash)
                guard let date = $0["listed_at"] as? String, listedAt = Trakt.datetimeFormatter.dateFromString(date) where media != nil else {
                    return nil
                }
                return (listedAt: listedAt, media: media!)
            }, nil)
        }
    }
}

public class TraktRequestGetWatched<T: TraktObject where T: protocol<Watchlist>>: TraktRequest {
    let type: T.Type
    public init(type: T.Type, extended: TraktRequestExtendedOptions? = nil) {
        self.type = type
        super.init(path: "/sync/watched/\(type.listName)", oAuth: true, params: extended?.value())
    }

    public func request(trakt: Trakt, completion: ([T]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(entries.flatMap {
                let media = self.type.init(data: $0[self.type.objectName] as? JSONHash)
                if let show = media as? TraktShow, sData = $0["seasons"] as? [JSONHash] {
                    show.seasons = sData.flatMap { TraktSeason(data: $0) }
                }
                return media
            }, nil)
        }
    }
}


/// Request to add object to your watchlist
public class TraktRequestAddToWatchlist: TraktRequest {
    public init(list: [TraktType: [TraktIdentifier]]) {
        var params: JSONHash = [:]
        list.forEach { type, values in
            params[type.rawValue] = values.flatMap { value in
                [
                    "ids": [
                        "trakt": value
                    ],
                ]
            }
        }
        super.init(method: "POST", path: "/sync/watchlist", params: params, oAuth: true)
    }

    public func request(trakt: Trakt, completion: ((added: [TraktType: Int]?, existing: [TraktType: Int]?, notFound: [TraktType: [TraktIdentifier]]?)?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let items = response.result.value as? JSONHash,
                added = items["added"] as? [String: Int],
                existing = items["existing"] as? [String: Int],
                notFound = items["not_found"] as? [String: [JSONHash]] else {
                return completion(nil, response.result.error)
            }

            var aItems: [TraktType: Int]? = [:]
            var eItems: [TraktType: Int]? = [:]
            var nItems: [TraktType: [TraktIdentifier]]? = [:]
            added.forEach {
                guard let type = TraktType(rawValue: $0.0) where $0.1 > 0 else {
                    return
                }
                aItems?[type] = $0.1
            }
            if aItems?.count == 0 {
                aItems = nil
            }
            existing.forEach {
                guard let type = TraktType(rawValue: $0.0) where $0.1 > 0 else {
                    return
                }
                eItems?[type] = $0.1
            }
            if eItems?.count == 0 {
                eItems = nil
            }
            notFound.forEach {
                guard let type = TraktType(rawValue: $0.0) else {
                    return
                }
                nItems?[type] = $0.1.flatMap { object in
                    (object["ids"] as? [String: TraktIdentifier])?["trakt"]
                }
                if nItems?[type]?.count == 0 {
                    nItems?.removeValueForKey(type)
                }
            }
            if nItems?.count == 0 {
                nItems = nil
            }
            completion((added: aItems, existing: eItems, notFound: nItems), response.result.error)
        }
    }
}


public class TraktRequestRemoveFromWatchlist: TraktRequest {
    public init(list: [TraktType: [TraktIdentifier]]) {
        var params: JSONHash = [:]
        list.forEach { type, values in
            params[type.rawValue] = values.flatMap { value in
                [
                    "ids": [
                        "trakt": value
                    ],
                ]
            }
        }
        super.init(method: "POST", path: "/sync/watchlist/remove", params: params, oAuth: true)
    }

    public func request(trakt: Trakt, completion: ((deleted: [TraktType: Int]?, notFound: [TraktType: [TraktIdentifier]]?)?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let items = response.result.value as? JSONHash,
                deleted = items["deleted"] as? [String: Int],
                notFound = items["not_found"] as? [String: [JSONHash]] else {
                    return completion(nil, response.result.error)
            }

            var dItems: [TraktType: Int]? = [:]
            var nItems: [TraktType: [TraktIdentifier]]? = [:]
            deleted.forEach {
                guard let type = TraktType(rawValue: $0.0) where $0.1 > 0 else {
                    return
                }
                dItems?[type] = $0.1
            }
            if dItems?.count == 0 {
                dItems = nil
            }
            notFound.forEach {
                guard let type = TraktType(rawValue: $0.0) else {
                    return
                }
                nItems?[type] = $0.1.flatMap { object in
                    (object["ids"] as? [String: TraktIdentifier])?["trakt"]
                }
                if nItems?[type]?.count == 0 {
                    nItems?.removeValueForKey(type)
                }
            }
            if nItems?.count == 0 {
                nItems = nil
            }
            completion((deleted: dItems, notFound: nItems), response.result.error)
        }
    }
}
