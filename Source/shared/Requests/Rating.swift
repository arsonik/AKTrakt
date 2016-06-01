//
//  Rating.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestAddRatings: TraktRequest {
    public init(ratings: [TraktType: [(traktId: TraktIdentifier, rating: UInt, ratedAt: NSDate)]]) {
        var params: JSONHash = [:]
        ratings.forEach { type, values in
            params[type.rawValue] = values.flatMap { value in
                [
                    "rating": value.rating,
                    "rated_at": Trakt.datetimeFormatter.stringFromDate(value.ratedAt),
                    "ids": [
                        "trakt": value.traktId
                    ],
                ]
            }
        }
        super.init(method: "POST", path: "/sync/ratings", params: params, oAuth: true)
    }

    public func request(trakt: Trakt, completion: ((added: [TraktType: Int]?, notFound: [TraktType: [TraktIdentifier]]?)?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
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
                    (object["ids"] as? [String: TraktIdentifier])?["trakt"]
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
