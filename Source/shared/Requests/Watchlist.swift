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
        super.init(path: "/sync/watchlist/\(type.listName)", params: extended?.value(), oAuth: true, headers: sort?.value())
    }

    public func request(_ trakt: Trakt, completion: ([(listedAt: Date, media: T)]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            completion(entries.flatMap {
                var media: T? = self.type.init(data: $0[self.type.objectName] as? JSONHash)
                media?.watchlist = true
                guard let date = $0["listed_at"] as? String, let listedAt = Trakt.datetimeFormatter.date(from: date), media != nil else {
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
        super.init(path: "/sync/watched/\(type.listName)", params: extended?.value(), oAuth: true)
    }

    public func request(_ trakt: Trakt, completion: ([T]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(entries.flatMap {
                let media = self.type.init(data: $0[self.type.objectName] as? JSONHash)
                /// Digest other data like plays, last watched at ...
                media?.digest($0)
                return media
            }, nil)
        }
    }
}


/// Request to add object to your watchlist
public class TraktRequestAddToWatchlist<T: TraktObject where T: protocol<ObjectType>, T: protocol<ListType>>: TraktRequest {
    private let type: T.Type
    public init(type: T.Type, id: TraktIdentifier) {
        self.type = type

        let params: JSONHash = [
            type.listName: [
                [
                    "ids": [
                        "trakt": id
                    ],
                ]
            ]
        ]
        super.init(method: "POST", path: "/sync/watchlist", params: params, oAuth: true)
    }

    public func request(_ trakt: Trakt, completion: (Bool?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let items = response.result.value as? JSONHash,
                let added = items["added"] as? [String: Int],
                let value = added[self.type.listName]
                else {
                    return completion(nil, response.result.error)
            }

            completion(value == 1, response.result.error)
        }
    }
}

/// Request to remove an object from watchlist
public class TraktRequestRemoveFromWatchlist<T: TraktObject where T: protocol<ObjectType>, T: protocol<ListType>>: TraktRequest {
    private let type: T.Type
    public init(type: T.Type, id: TraktIdentifier) {
        self.type = type
        let params: JSONHash = [
            type.listName: [
                [
                    "ids": [
                        "trakt": id
                    ],
                ]
            ]
        ]
        super.init(method: "POST", path: "/sync/watchlist/remove", params: params, oAuth: true)
    }

    /**
     Execute request

     - parameter trakt:      trakt client
     - parameter completion: closure (bool: deleted, NSError?)

     - returns: Alamofire.Request
     */
    public func request(_ trakt: Trakt, completion: (Bool?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let items = response.result.value as? JSONHash,
                let added = items["deleted"] as? [String: Int],
                let value = added[self.type.listName]
                else {
                    return completion(nil, response.result.error)
            }

            completion(value == 1, response.result.error)
        }
    }
}
