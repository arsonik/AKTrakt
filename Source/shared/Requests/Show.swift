//
//  Show.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

public struct TraktRequestShow: TraktRequestGET, TraktRequestExtended {
    public var path: String
    public var params: JSONHash?

    public var extended: TraktRequestExtendedOptions?

    init(id: AnyObject, extended: TraktRequestExtendedOptions? = nil) {
        path = "/shows/\(id)"
        self.extended = extended
    }
}

extension Trakt {
    public func show(id: AnyObject, extended: TraktRequestExtendedOptions? = nil, completion: (TraktShow?, NSError?) -> Void) -> Request? {
        return request(TraktRequestShow(id: id, extended: extended)) { response in
            guard let item = response.result.value as? JSONHash, o = TraktShow(data: item) else {
                print("Cannot find object with id \(id)")
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }
}
