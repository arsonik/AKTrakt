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

    public var extendedInfo: [TraktRequestExtendedInfo]?

    init(id: AnyObject, extendedInfo: [TraktRequestExtendedInfo]? = nil) {
        path = "/shows/\(id)"
        self.extendedInfo = extendedInfo
    }
}

extension Trakt {
    public func show(id: AnyObject, extendedInfo: [TraktRequestExtendedInfo]? = nil, completion: (TraktShow?, NSError?) -> Void) -> Request? {

        return request(TraktRequestShow(id: id, extendedInfo: extendedInfo)) { response in
            guard let item = response.result.value as? JSONHash, o = TraktShow(data: item) else {
                print("Cannot find show \(id)")
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }
}
