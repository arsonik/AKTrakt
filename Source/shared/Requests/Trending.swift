//
//  Trending.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

/// Trending request show/movies
public class TraktRequestTrending<T: TraktObject where T: protocol<Trending>>: TraktRequest {
    /// request type
    private let type: T.Type

    /**
     Init request

     - parameter type:       TraktObject.Type that implements Trending example TraktRequestTrending(type: TraktMovie.self)
     - parameter extended:   extended params
     - parameter pagination: pagination params
     */
    public init(type: T.Type, extended: TraktRequestExtendedOptions? = nil, pagination: TraktPagination? = nil) {
        self.type = type
        var params: JSONHash = [:]
        if extended != nil {
            params += extended!.value()
        }
        if pagination != nil {
            params += pagination!.value()
        }
        super.init(path: "/\(type.listName)/trending", params: params)
    }

    /**
     Request

     - parameter trakt:      trakt client
     - parameter completion: closure list of result as tuple watchers, media, NSError?

     - returns: Alamofire.Request
     */
    public func request(_ trakt: Trakt, completion: ([(watchers: UInt, media: T)]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            let list: [(watchers: UInt, media: T)] = entries.flatMap {
                let media: T? = self.type.init(data: $0[self.type.objectName] as? JSONHash)
                guard let watchers = $0["watchers"] as? UInt, media != nil else {
                    return nil
                }
                return (watchers: watchers, media: media!)
            }
            completion(list, response.result.error)
        }
    }
}
