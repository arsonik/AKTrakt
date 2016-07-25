//
//  Rating.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

/// Add rate to an object
public class TraktRequestAddRating<T: TraktObject where T: protocol<ObjectType>, T: protocol<ListType>>: TraktRequest {
    private var type: T.Type
    /**
     Init request

     - parameter type:      type (ex: TraktMovie.self)
     - parameter id:        id
     - parameter rating:  rating 0 to 10
     - parameter ratedAt: rate date optional
     */
    public init(type: T.Type, id: TraktIdentifier, rating: UInt, ratedAt: Date = Date()) {
        self.type = type
        let params: JSONHash = [
            type.listName: [
                [
                    "rating": rating,
                    "rated_at": Trakt.datetimeFormatter.string(from: ratedAt),
                    "ids": [
                        "trakt": id
                    ]
                ]
            ]
        ]
        super.init(method: "POST", path: "/sync/ratings", params: params, oAuth: true)
    }

    /**
     Execute request

     - parameter trakt:      trakt client
     - parameter completion: closure success, error

     - returns: Alamofire.Request
     */
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
