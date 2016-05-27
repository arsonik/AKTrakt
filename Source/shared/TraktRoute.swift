//
//  TraktRoute.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

/// Trakt routes
/// All the routes used in the main class
public enum TraktRoute: URLRequestConvertible, Hashable {
    ///	Remove From Watchlist Movies/Shows/Episodes
    case RemoveFromWatchlist([protocol<TraktIdentifiable, Watchable>])
    ///	Remove from Watched History Movies/Shows/Episodes
    case RemoveFromHistory([protocol<TraktIdentifiable, Watchable>])
    ///	Get Progress for a show
    case Progress(TraktShow)

    /// Get seasons for a show (or single season if number passed)
    case Season(AnyObject, Int?)

    /// Create a unique identifier for that route
    public var hashValue: Int {
        var uniqid = method + path
        uniqid += (parameters?.flatMap({
            "\($0)=\($1)"
        }).joinWithSeparator(",")) ?? ""
        return uniqid.hashValue
    }

    private var method: String {
        switch self {
        case .RemoveFromHistory, .RemoveFromWatchlist:
            return "POST"
        default:
            return "GET"
        }
    }

    private func anyObjectToId(id: AnyObject) -> String {
        return "\(id)".stringByReplacingOccurrencesOfString(" ", withString: "-")
    }

    private var path: String {
        switch self {
        case .Season(let id, let number):       return "/shows/\(anyObjectToId(id))/seasons\(number != nil ? "/\(number!)" : "")"
        case .Progress(let show):				return "/shows/\(show.id)/progress/watched"
        case .RemoveFromHistory:				return "/sync/history/remove"
        case .RemoveFromWatchlist:				return "/sync/watchlist/remove"
        }
    }

    private var parameters: [String: AnyObject]! {
        switch self {
        case .Progress, .Season:
            return ["extended": "full,images"]

        case .RemoveFromWatchlist(let objects):
            var p: [String: [[String: [String: TraktIdentifier]]]] = [:]
            objects.forEach { object in
                if p[object.type.rawValue] == nil {
                    p[object.type.rawValue] = []
                }
                p[object.type.rawValue]?.append(["ids": [TraktId.Trakt.rawValue: object.id]])
            }
            return p

        case .RemoveFromHistory(let objects):
            var p: [String: [[String: AnyObject]]] = [:]
            for object in objects {
                p[object.type.rawValue]?.append(["ids": ["trakt": object.id]])
            }
            return p

        default:
            return nil
        }
    }

    public var URLRequest: NSMutableURLRequest {
        guard let url = NSURL(string: "https://api-v2launch.trakt.tv\(path)") else {
            fatalError("Url with missing path ? \(path)")
        }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return (method == "POST" ? ParameterEncoding.JSON : ParameterEncoding.URL).encode(request, parameters: parameters).0
    }

    internal func needAuthorization() -> Bool {
        switch self {
        case .Season:
            return false
        default:
            return true
        }
    }
}

public func == (left: TraktRoute, right: TraktRoute) -> Bool {
    return left.hashValue == right.hashValue
}
