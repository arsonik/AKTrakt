//
//  TraktRoute.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

public class TraktRequestProfile: TraktRequest {
    init(username: String? = nil) {
        super.init(path: "/users/\((username ?? "me"))", tokenRequired: true)
    }
}


/// Trakt routes
/// All the routes used in the main class
public enum TraktRoute: URLRequestConvertible, Hashable {
    ///	Get Collection Movies/Shows
    case Collection(TraktType)

    ///	Get Watchlist Movies/Shows/Seasons/Episodes
    case Watchlist(TraktType)

    ///	Get Watched Movies/Shows
    case Watched(TraktType)
    ///	Add to Watchlist Movies/Shows/Episodes
    case AddToWatchlist([protocol<TraktIdentifiable, Watchable>])
    ///	Remove From Watchlist Movies/Shows/Episodes
    case RemoveFromWatchlist([protocol<TraktIdentifiable, Watchable>])
    ///	Add to Watched History Movies/Shows/Episodes
    case AddToHistory([protocol<TraktIdentifiable, Watchable>])
    ///	Remove from Watched History Movies/Shows/Episodes
    case RemoveFromHistory([protocol<TraktIdentifiable, Watchable>])
    ///	Hide from recommendations Movies/Shows
    case HideRecommendation(protocol<TraktIdentifiable, Watchable>)
    ///	Get Progress for a show
    case Progress(TraktShow)
    ///	Find an episode by its show id, season number, episode number
    case Episode(showId: AnyObject, season: Int, episode: Int)

    /// Get seasons for a show (or single season if number passed)
    case Season(AnyObject, Int?)

    ///	Search based on query with optional type, pagination
    case Search(query: String, type: TraktType!, year: Int!, TraktPagination)

    /// Load user (retrieve current if nil argument)
    case Profile(String!)
    /// Get Movie Releases
    case Releases(TraktMovie, countryCode: String!)

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
        case .AddToHistory, .RemoveFromHistory, .AddToWatchlist, .RemoveFromWatchlist:
            return "POST"
        case .HideRecommendation:
            return "DELETE"
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
        case .Episode(let showId, let season, let episode):
												return "/shows/\(showId)/seasons/\(season)/episodes/\(episode)"
        case .Collection(let type):				return "/sync/collection/\(type.rawValue)"
        case .Watchlist(let type):				return "/sync/watchlist/\(type.rawValue)"
        case .Watched(let type):				return "/sync/watched/\(type.rawValue)"
        case .Progress(let show):				return "/shows/\(show.id)/progress/watched"
        case .AddToHistory:						return "/sync/history"
        case .RemoveFromHistory:				return "/sync/history/remove"
        case .AddToWatchlist:					return "/sync/watchlist"
        case .RemoveFromWatchlist:				return "/sync/watchlist/remove"
        case .Search:							return "/search"
        case .HideRecommendation(let object):   return "/recommendations/\(object.type.rawValue)/\(object.id)"
        case .Profile(let name):				return "/users/\((name ?? "me"))"
        case .Releases(let movie, let countryCode):
            return "/movies/\((movie.id))/releases/\((countryCode ?? ""))"
        }
    }

    private var parameters: [String: AnyObject]! {
        switch self {
        case .Watchlist, .Collection, .Progress, .Episode, .Watched, .Season:
            return ["extended": "full,images"]

        case .AddToWatchlist(let objects):
            var p: [String: [[String: [String: TraktIdentifier]]]] = [:]
            objects.forEach { object in
                if p[object.type.rawValue] == nil {
                    p[object.type.rawValue] = []
                }
                p[object.type.rawValue]?.append(["ids": [TraktId.Trakt.rawValue: object.id]])
            }
            return p

        case .RemoveFromWatchlist(let objects):
            var p: [String: [[String: [String: TraktIdentifier]]]] = [:]
            objects.forEach { object in
                if p[object.type.rawValue] == nil {
                    p[object.type.rawValue] = []
                }
                p[object.type.rawValue]?.append(["ids": [TraktId.Trakt.rawValue: object.id]])
            }
            return p

        case .AddToHistory(let objects):
            var p: [String: [[String: AnyObject]]] = [:]
            for object in objects {
                if p[object.type.rawValue] == nil {
                    p[object.type.rawValue] = []
                }
                p[object.type.rawValue]?.append(["ids": ["trakt": object.id]])
            }
            return p

        case .RemoveFromHistory(let objects):
            var p: [String: [[String: AnyObject]]] = [:]
            for object in objects {
                p[object.type.rawValue]?.append(["ids": ["trakt": object.id]])
            }
            return p

        case .Search(let query, let type, let year, let pagination):
            var p = pagination.value()
            p["query"] = query
            if let v = type {
                p["type"] = v.single
            }
            if let v = year {
                p["year"] = v
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
        case .Episode,
             .Season,
             .Search:
            return false
        default:
            return true
        }
    }
}

public func == (left: TraktRoute, right: TraktRoute) -> Bool {
    return left.hashValue == right.hashValue
}
