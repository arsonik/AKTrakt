//
//  Movie.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation
import Alamofire

public struct TraktRequestMovie: TraktRequestGET, TraktRequestExtended {
    public var path: String
    public var params: JSONHash?

    public var extended: TraktRequestExtendedOptions?

    init(id: AnyObject, extended: TraktRequestExtendedOptions? = nil) {
        path = "/movies/\(id)"
        self.extended = extended
    }
}

extension Trakt {
    public func movie(id: AnyObject, extended: TraktRequestExtendedOptions? = nil, completion: (TraktMovie?, NSError?) -> Void) -> Request? {
        return request(TraktRequestMovie(id: id, extended: extended)) { response in
            guard let item = response.result.value as? JSONHash, o = TraktMovie(data: item) else {
                print("Cannot find object with id \(id)")
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }
}
