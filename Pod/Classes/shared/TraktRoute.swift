//
//  TraktRoute.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

public func == (left: TraktRoute, right: TraktRoute) -> Bool {
	return left.hashValue == right.hashValue
}

public enum TraktRoute: URLRequestConvertible, Hashable {
	case Token(client: Trakt, pin: String)
	case Trending(TraktType, TraktPagination)
	case Recommandations(TraktType, TraktPagination)
    case Collection(TraktType)
    case Watchlist(TraktType)
    case People(TraktType, TraktIdentifier)
    case Credits(TraktIdentifier, TraktType)
	case Watched(TraktType)
	case AddToWatchlist([TraktObject])
	case AddToHistory([TraktObject])
    case RemoveFromHistory([TraktObject])
    case HideRecommendation(TraktMovie)
	case Progress(AnyObject)
	case Episode(showId: AnyObject, season: Int, episode: Int)
	case Movie(id: AnyObject)
	case Search(query: String, type: TraktType!, year: Int!, TraktPagination)
	case Rate(TraktWatchable, Int)

	/// Create a unique identifier for that route
	public var hashValue: Int {
		var uniqid = method + path
		uniqid += (parameters?.flatMap({
			"\($0)=\($1)"
		}).joinWithSeparator(",")) ?? ""
		return uniqid.hashValue
	}

	private var domain: String {
		switch self {
		default:
			return "https://api-v2launch.trakt.tv"
		}
	}

	private var method: String {
		switch self {
		case .Token, .AddToHistory, .RemoveFromHistory, .AddToWatchlist, .Rate:
			return "POST"
        case .HideRecommendation:
            return "DELETE"
		default:
			return "GET"
		}
	}

	private var headers: [String: String]? {
		switch self {
		default:
			return nil
		}
	}

	private var path: String {
		switch self {
		case .Token:							return "/oauth/token"
		case .Trending(let type, _):			return "/\(type.rawValue)/trending"
        case .Recommandations(let type, _):		return "/recommendations/\(type.rawValue)"
		case .Movie(let id):					return "/movies/\(id)"
		case .Episode(let showId, let season, let episode):
												return "/shows/\(showId)/seasons/\(season)/episodes/\(episode)"
		case .Collection(let type):				return "/sync/collection/\(type.rawValue)"
		case .Watchlist(let type):				return "/sync/watchlist/\(type.rawValue)"
        case .Watched(let type):				return "/sync/watched/\(type.rawValue)"
        case .Progress(let id):					return "/shows/\(id)/progress/watched"
        case .People(let type, let id):			return "/\(type.rawValue)/\(id)/people"
		case .AddToHistory:						return "/sync/history"
		case .RemoveFromHistory:				return "/sync/history/remove"
		case .AddToWatchlist:					return "/sync/watchlist"
		case .Search:							return "/search"
        case .Rate:								return "/sync/ratings"
        case .Credits(let id, let type):        return "/people/\(id)/\(type.rawValue)"

        case .HideRecommendation(let movie):    return "/recommendations/movies/\(movie.id!)"
		}
	}

	private var parameters: [String: AnyObject]! {
		switch self {
		case .Token(let trakt, let pin):
			return [
				"code": pin,
				"client_id": trakt.clientId,
				"client_secret": trakt.clientSecret,
				"redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
				"grant_type": "authorization_code"
			]
		case .Watchlist, .Collection, .Progress, .Episode, .Movie, .People, .Credits:
			return ["extended": "full,images"]

		case .Trending(_, let pagination):
			var p = pagination.value()
			p["extended"] = "full,images"
			return p
			
		case .Recommandations(_, let pagination):
			var p = pagination.value()
			p["extended"] = "full,images"
			return p

        case .AddToWatchlist(let objects):
            var p: [String: [[String: [String: TraktIdentifier]]]] = [:]
            for object in objects {
                if let id = object.id {
                    if p[object.type!.rawValue] == nil {
                        p[object.type!.rawValue] = []
                    }
                    p[object.type!.rawValue]?.append(["ids": ["trakt": id]])
                }
            }
            return p

		case .AddToHistory(let objects):
			var p: [String: [[String: AnyObject]]] = [:]
			for object in objects {
				if let id = object.ids[TraktId.Trakt] as? Int {

					if p[object.type!.rawValue] == nil {
						p[object.type!.rawValue] = []
					}
					p[object.type!.rawValue]?.append(["ids": ["trakt": id]])
				}
			}
			return p

		case .RemoveFromHistory(let objects):
			var p: [String: [[String: AnyObject]]] = [:]
			for object in objects {
				if let id = object.ids[TraktId.Trakt] as? Int {

					if p[object.type!.rawValue] == nil {
						p[object.type!.rawValue] = []
					}
					p[object.type!.rawValue]?.append(["ids": ["trakt": id]])
				}
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

		case .Rate(let object, let rate):
			var p: [String: [AnyObject]] = [:]
			let e: [String: AnyObject] = [
				"rating": rate,
				"ids": ["trakt": object.id!]
			]
			p["\(object.type!.rawValue)"] = [e]
			return p

		default:
			return nil
		}
	}

	public var URLRequest: NSMutableURLRequest {
		let request = NSMutableURLRequest(URL: NSURL(string: "\(domain)\(path)")!)
		request.HTTPMethod = method
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		headers?.forEach{ key, value in
			request.setValue(value, forHTTPHeaderField: key)

		}
		switch self {
		case .Token, .AddToHistory, .RemoveFromHistory, .AddToWatchlist, .Rate:
			let encoding = Alamofire.ParameterEncoding.JSON
			return encoding.encode(request, parameters: parameters).0
		default:
			let encoding = Alamofire.ParameterEncoding.URL
			return encoding.encode(request, parameters: parameters).0
		}
	}

	internal func needAuthorization() -> Bool {
		switch self {
		case .Token:
			return false
		default:
			return true
		}
	}

	func OAuthRequest(trakt: Trakt) -> NSMutableURLRequest {
		let req = URLRequest
		req.setValue("2", forHTTPHeaderField: "trakt-api-version")
		req.setValue(trakt.clientId, forHTTPHeaderField: "trakt-api-key")
		if let token = trakt.token {
			req.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
		}
		return req
	}
}

public class TraktPagination {
	var page: Int = 1
	var limit: Int = 10

	public init(page: Int, limit: Int) {
		self.page = page
		self.limit = limit
	}

	func value() -> [String: AnyObject] {
		return [
			"page": page,
			"limit": limit
		]
	}
}