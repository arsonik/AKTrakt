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
	///	Generate new device codes
	case GenerateCode(clientId: String)
	///	Poll for the access_token
	case PollDevice(deviceCode: String, clientId: String, clientSecret: String)
	///	Exchange code for access_token
	case Token(client: Trakt, pin: String)
	///	Get Trending Movies/Shows
	case Trending(TraktType, TraktPagination)
	///	Get Recommendations Movies/Shows
	case Recommandations(TraktType, TraktPagination)
	///	Get Collection Movies/Shows
	case Collection(TraktType)
	///	Get Watchlist Movies/Shows/Seasons/Episodes
	case Watchlist(TraktType)
	///	Get Movies/Shows Credits for a person
	case People(TraktType, TraktIdentifier)
	///	Get Movies/Shows Credits
	case Credits(TraktIdentifier, TraktType)
	///	Get Watched Movies/Shows
	case Watched(TraktType)
	///	Add to Watchlist Movies/Shows/Episodes
	case AddToWatchlist([TraktWatchable])
	///	Remove From Watchlist Movies/Shows/Episodes
	case RemoveFromWatchlist([TraktWatchable])
	///	Add to Watched History Movies/Shows/Episodes
	case AddToHistory([TraktWatchable])
	///	Remove from Watched History Movies/Shows/Episodes
	case RemoveFromHistory([TraktWatchable])
	///	Hide from recommendations Movies/Shows
	case HideRecommendation(TraktWatchable)
	///	Get Progress for a show
	case Progress(TraktShow)
	///	Find an episode by its show id, season number, episode number
	case Episode(showId: AnyObject, season: Int, episode: Int)
	///	Find a movie by its id (slug...)
	case Movie(id: String)
    /// Find a show by its id(slug...)
    case Show(id: String)
	///	Search based on query with optional type, pagination
	case Search(query: String, type: TraktType!, year: Int!, TraktPagination)
	/// Rate something from 1-10
	case Rate(TraktWatchable, Int)
	/// Load a user
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

	private var domain: String {
		switch self {
		default:
			return "https://api-v2launch.trakt.tv"
		}
	}

	private var method: String {
		switch self {
		case .GenerateCode, .PollDevice, .Token, .AddToHistory, .RemoveFromHistory, .AddToWatchlist, .Rate, .RemoveFromWatchlist:
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
		case .PollDevice:						return "/oauth/device/token"
		case .GenerateCode:						return "/oauth/device/code"
		case .Token:							return "/oauth/token"
		case .Trending(let type, _):			return "/\(type.rawValue)/trending"
        case .Recommandations(let type, _):		return "/recommendations/\(type.rawValue)"
		case .Movie(let id):					return "/movies/\(id)"
        case .Show(let id):                     return "/shows/\(id)"
		case .Episode(let showId, let season, let episode):
												return "/shows/\(showId)/seasons/\(season)/episodes/\(episode)"
		case .Collection(let type):				return "/sync/collection/\(type.rawValue)"
		case .Watchlist(let type):				return "/sync/watchlist/\(type.rawValue)"
        case .Watched(let type):				return "/sync/watched/\(type.rawValue)"
        case .Progress(let show):				return "/shows/\(show.id)/progress/watched"
        case .People(let type, let id):			return "/\(type.rawValue)/\(id)/people"
		case .AddToHistory:						return "/sync/history"
		case .RemoveFromHistory:				return "/sync/history/remove"
		case .AddToWatchlist:					return "/sync/watchlist"
		case .RemoveFromWatchlist:				return "/sync/watchlist/remove"
		case .Search:							return "/search"
        case .Rate:								return "/sync/ratings"
        case .Credits(let id, let type):        return "/people/\(id)/\(type.rawValue)"
		case .HideRecommendation(let object):   return "/recommendations/\(object.type!.rawValue)/\(object.id)"
		case .Profile(let name):				return "/users/\((name ?? "me"))"
		case .Releases(let movie, let countryCode):
			return "/movies/\((movie.id))/releases/\((countryCode ?? ""))"
		}
	}

	private var parameters: [String: AnyObject]! {
		switch self {
		case .PollDevice(let deviceCode, let clientId, let clientSecret):
			return [
				"client_id": clientId,
				"client_secret": clientSecret,
				"code": deviceCode,
			]

		case .GenerateCode(let clientId):
			return [
				"client_id": clientId
			]

		case .Token(let trakt, let pin):
			return [
				"code": pin,
				"client_id": trakt.clientId,
				"client_secret": trakt.clientSecret,
				"redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
				"grant_type": "authorization_code"
			]
		case .Watchlist, .Collection, .Progress, .Episode, .Movie, .Show, .People, .Credits, .Watched:
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
            objects.forEach { object in
                if let id = object.id, type = object.type?.rawValue {
                    if p[type] == nil {
                        p[type] = []
                    }
                    p[type]?.append(["ids": [TraktId.Trakt.rawValue: id]])
                }
            }
            return p

		case .RemoveFromWatchlist(let objects):
			var p: [String: [[String: [String: TraktIdentifier]]]] = [:]
			objects.forEach { object in
				if let id = object.id, type = object.type?.rawValue {
					if p[type] == nil {
						p[type] = []
					}
					p[type]?.append(["ids": [TraktId.Trakt.rawValue: id]])
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
		case .GenerateCode, .PollDevice, .Token, .AddToHistory, .RemoveFromHistory, .AddToWatchlist, .RemoveFromWatchlist, .Rate:
			let encoding = Alamofire.ParameterEncoding.JSON
			return encoding.encode(request, parameters: parameters).0
		default:
			let encoding = Alamofire.ParameterEncoding.URL
			return encoding.encode(request, parameters: parameters).0
		}
	}

	func retryOnFailure() -> Bool {
		switch self {
		case .PollDevice:
			return false
		default:
			return true
		}
	}

	internal func needAuthorization() -> Bool {
		switch self {
		case .Token,
			.GenerateCode,
			.PollDevice,
			.People,
			.Credits,
			.Trending,
			.Movie,
			.Episode,
			.Search:
			return false
		default:
			return true
		}
	}
}

/// TraktRoute Equatable function
public func == (left: TraktRoute, right: TraktRoute) -> Bool {
	return left.hashValue == right.hashValue
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