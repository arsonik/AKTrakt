//
//  Sync.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation
import Alamofire

/// Collection request show/movies
public class TraktRequestGetCollection<T: TraktObject where T: ListType, T: ObjectType>: TraktRequest {
    /// request type
    private var type: T.Type

    /**
     Init request with a type, and extended info

     - parameter type:     type (ex: TraktMovie.self)
     - parameter extended: extended data (ex: [.Full, .Images] or .Min)
     */
    public init(type: T.Type, extended: TraktRequestExtendedOptions = .Min) {
        self.type = type
        super.init(path: "/sync/collection/\(type.listName)", params: extended.value(), oAuth: true)
    }

    /**
     Execute the request

     - parameter trakt:      trakt Client
     - parameter completion: closure ([TraktObject]?, NSError?)

     - returns: Alamofire.Request
     */
    public func request(_ trakt: Trakt, completion: ([T]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            let list: [T] = entries.flatMap {
                let media: T? = self.type.init(data: $0[self.type.objectName] as? JSONHash)
                if var object = media as? Collectable,
                    let date = $0["collected_at"] as? String,
                    let collectedAt = Trakt.datetimeFormatter.date(from: date) {
                        object.collectedAt = collectedAt
                }
                if let show = media as? TraktShow, let seasonsData = $0["seasons"] as? [JSONHash] {
                    show.seasons = seasonsData.flatMap {
                        TraktSeason(data: $0)
                    }
                }

                return media
            }
            completion(list, nil)
        }
    }
}
