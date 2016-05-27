//
//  History.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestAddToHistory: TraktRequest, TraktRequest_Completion {
    public init(list: [TraktType: [(traktId: TraktIdentifier, watchedAt: NSDate)]]) {
        var params: JSONHash = [:]
        list.forEach { type, values in
            params[type.rawValue] = values.flatMap { value in
                [
                    "watched_at": Trakt.datetimeFormatter.stringFromDate(value.watchedAt),
                    "ids": [
                        "trakt": value.traktId
                    ],
                ]
            }
        }
        super.init(method: "POST", path: "/sync/history", params: params, oAuth: true)
    }

    public func request(trakt: Trakt, completion: ((added: [TraktType: Int]?, notFound: [TraktType: [TraktIdentifier]]?)?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let items = response.result.value as? JSONHash, added = items["added"] as? [String: Int], notFound = items["not_found"] as? [String: [JSONHash]] else {
                return completion(nil, response.result.error)
            }

            var aItems: [TraktType: Int]? = [:]
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
            notFound.forEach {
                guard let type = TraktType(rawValue: $0.0) else {
                    return
                }
                nItems?[type] = $0.1.flatMap { object in
                    (object["ids"] as? [String: Int])?["trakt"]
                }
                if nItems?[type]?.count == 0 {
                    nItems?.removeValueForKey(type)
                }
            }
            if nItems?.count == 0 {
                nItems = nil
            }
            completion((added: aItems, notFound: nItems), response.result.error)
        }
    }
}

public class TraktRequestRemoveFromHistory: TraktRequest, TraktRequest_Completion {
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
        super.init(method: "POST", path: "/sync/history/remove", params: params, oAuth: true)
    }

    public func request(trakt: Trakt, completion: ((deleted: [TraktType: Int]?, notFound: [TraktType: [TraktIdentifier]]?)?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
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
                    (object["ids"] as? [String: Int])?["trakt"]
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
