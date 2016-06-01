//
//  Search.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

/// Serarch request
public class TraktRequestSearch: TraktRequest {
    /**
     Init

     - parameter query:      search query string
     - parameter type:       optional trakt type
     - parameter year:       optional year
     - parameter pagination: optional pagination
     */
    public init(query: String, type: TraktType? = nil, year: UInt? = nil, pagination: TraktPagination? = nil) {
        var params: JSONHash = [
            "query": query
        ]
        if year != nil {
            params["year"] = year!
        }
        if type != nil {
            params["type"] = type!.single
        }
        if pagination != nil {
            params += pagination!.value()
        }
        super.init(path: "/search", params: params)
    }

    /**
     Execute request

     - parameter trakt:      trakt client
     - parameter completion: closure [TraktObject]?, NSError?

     - returns: Alamofire.Request
     */
    public func request(trakt: Trakt, completion: ([TraktObject]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            completion(entries.flatMap {
                guard let type = TraktType.init(single: $0["type"] as? String ?? "") else {
                    return nil
                }
                return type.classType?.init(data: $0[type.single] as? JSONHash)
            }, nil)
        }
    }
}
