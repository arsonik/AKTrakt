//
//  Trending.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestTrending: TraktRequest, TraktRequest_Completion {
    var type: TraktMediaType

    public init(type: TraktMediaType, extended: TraktRequestExtendedOptions? = nil, pagination: TraktPagination? = nil) {
        self.type = type
        var params: JSONHash = [:]
        if extended != nil {
            params += extended!.value()
        }
        if pagination != nil {
            params += pagination!.value()
        }
        super.init(path: "/\(type.rawValue)/trending", params: params)
    }

    public func request(trakt: Trakt, completion: ([(watchers: UInt, media: TraktObject)]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            let list: [(watchers: UInt, media: TraktObject)] = entries.flatMap {
                let mediaData = $0[self.type.single] as? JSONHash
                let media: TraktObject? = self.type == .Shows ? TraktShow(data: mediaData) : TraktMovie(data: mediaData)
                guard let watchers = $0["watchers"] as? UInt where media != nil else {
                    return nil
                }
                return (watchers: watchers, media: media!)
            }
            completion(list, response.result.error)
        }
    }
}
