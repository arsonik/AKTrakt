//
//  TraktRequest.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

// Define a request (abstract) used by the api
public class TraktRequest {
    /// HTTP Method
    public let method: String
    /// Path
    public let path: String
    /// Params
    public let params: JSONHash?
    /// OAuth required ?
    public let oAuth: Bool
    /// HTTP Headers
    public let headers: [String: String]?
    /// Numbers of attemps in case of failure
    public var attemptLeft: Int = 5

    /**
     Init

     - parameter method:  method
     - parameter path:    path
     - parameter params:  params
     - parameter oAuth:   oAuth
     - parameter headers: headers
     */
    public init(method: String = "GET", path: String, params: JSONHash? = nil, oAuth: Bool = false, headers: [String: String]? = [:]) {
        self.method = method
        self.path = path
        self.params = params
        self.oAuth = oAuth
        self.headers = headers
    }
}

/// Represents the sorting headers used by Trakt
public struct TraktSortHeaders: TraktRequestHeaders {
    public let sortBy: String = "rank"
    public let sortHow: String = "asc"

    /**
     Get values according to protocol

     - returns: JSONHash
     */
    public func value() -> [String : String] {
        return [
            "X-Sort-By": sortBy,
            "X-Sort-How": sortHow
        ]
    }
}

/// Represents the pagination params used by Trakt
public struct TraktPagination: TraktURLParameters {
    /// current page
    var page: Int = 1
    /// current limit
    var limit: Int = 10

    /**
     Init

     - parameter page:  page
     - parameter limit: limit
     */
    public init(page: Int, limit: Int) {
        self.page = page
        self.limit = limit
    }

    /**
     Get values according to protocol

     - returns: JSONHash
     */
    public func value() -> JSONHash {
        return [
            "page": page,
            "limit": limit
        ]
    }
}

/// Represents the extended params used by Trakt
public struct TraktRequestExtendedOptions: OptionSetType, TraktURLParameters {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let Min = TraktRequestExtendedOptions(rawValue: 0)
    public static let Images = TraktRequestExtendedOptions(rawValue: 1 << 0)
    public static let Full = TraktRequestExtendedOptions(rawValue: 1 << 1)
    public static let Metadata = TraktRequestExtendedOptions(rawValue: 1 << 2)
    public static let NoSeasons = TraktRequestExtendedOptions(rawValue: 1 << 3)
    public static let Episodes = TraktRequestExtendedOptions(rawValue: 1 << 4)

    /**
     Get values according to protocol

     - returns: JSONHash
     */
    public func value() -> JSONHash {
        var list: [String] = []
        if contains(.Full) {
            list.append("full")
        }
        if contains(.Images) {
            list.append("images")
        }
        if contains(.Metadata) {
            list.append("metadata")
        }
        if contains(.NoSeasons) {
            list.append("noseasons")
        }
        if contains(.Episodes) {
            list.append("episodes")
        }
        return ["extended": list.joinWithSeparator(",")]
    }
}

extension Trakt {
    /**
     Execute a request within the client

     - parameter request:           request to be executed
     - parameter completionHandler: completion handler

     - returns: Alamofire.Request
     */
    public func request(request: TraktRequest, completionHandler: Response<AnyObject, NSError> -> Void) -> Request? {
        do {
            guard let url = NSURL(string: "https://api-v2launch.trakt.tv\(request.path)") else {
                throw TraktError.UrlError
            }
            let mRequest = NSMutableURLRequest(URL: url)
            mRequest.HTTPMethod = request.method

            mRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            mRequest.setValue("\(traktApiVersion)", forHTTPHeaderField: "trakt-api-version")
            mRequest.setValue(clientId, forHTTPHeaderField: "trakt-api-key")

            if request.oAuth {
                if let accessToken = token?.accessToken {
                    mRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                } else {
                    throw TraktError.TokenRequired
                }
            }

            request.headers?.forEach {
                mRequest.setValue($0.1, forHTTPHeaderField: $0.0)
            }

            let pRequest = (mRequest.HTTPMethod == "POST" ? ParameterEncoding.JSON : ParameterEncoding.URL).encode(mRequest, parameters: request.params).0

            request.attemptLeft -= 1
            return manager.request(pRequest).responseJSON { [weak self] response in
                guard let ss = self else {
                    completionHandler(response)
                    return
                }

                if response.response?.statusCode >= 500 {
                    if request.attemptLeft > 0 {
                        // try again after delay
                        return delay(ss.retryInterval) {
                            ss.request(request, completionHandler: completionHandler)
                            return
                        }
                    } else {
                        print("Maximum attempt reached for request \(request)")
                    }
                }
                completionHandler(response)
            }
        } catch {
            return nil
        }
    }
}
