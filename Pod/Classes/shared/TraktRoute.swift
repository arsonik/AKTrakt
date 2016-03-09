//
//  TraktRoute.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

public enum TraktRoute: URLRequestConvertible {

	case Token(client: Trakt, pin: String)
	case Trending(TraktType)
	case Recommandations(TraktType)
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
	case Search(query: String, type: TraktType!, year: Int!)
	case Rate(TraktWatchable, Int)

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
		case .Trending(let type):				return "/\(type.rawValue)/trending"
        case .Recommandations(let type):		return "/recommendations/\(type.rawValue)"
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

		case .Trending, .Recommandations:
			return ["extended": "full,images", "limit": "100"]

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

		case .Search(let query, let type, let year):
			var p: [String: AnyObject] = [
				"query": query,
				"limit": 5
			]
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
		if let url = NSURL(string: "\(domain)\(path)") {
			let URLRequest = NSMutableURLRequest(URL: url)
			URLRequest.HTTPMethod = method
			URLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
			if let hl = headers {
				for (k, v) in hl {
					URLRequest.setValue(v, forHTTPHeaderField: k)
				}
			}

			switch self {
			case .Token, .AddToHistory, .RemoveFromHistory, .AddToWatchlist, .Rate:
				let encoding = Alamofire.ParameterEncoding.JSON
				return encoding.encode(URLRequest, parameters: parameters).0
			default:
				let encoding = Alamofire.ParameterEncoding.URL
				return encoding.encode(URLRequest, parameters: parameters).0
			}
		} else {
			return NSMutableURLRequest()
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
