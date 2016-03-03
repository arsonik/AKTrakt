//
//  TraktRoute.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

public enum TraktRoute :URLRequestConvertible {
	
    case Token(client:Trakt, pin:String)
    , TrendingMovies
    , TrendingShows
    , RecommandationsMovies
    , Collection(TraktType)
    , Watchlist(TraktType)
    , People(TraktType, TraktIdentifier)
	, Watched(TraktType)
	, addToWatchlist([TraktObject])
	, addToHistory([TraktObject])
    , removeFromHistory([TraktObject])
    , HideRecommendation(TraktMovie)
	, Progress(AnyObject)
	, Episode(showId:AnyObject, season:Int, episode:Int)
	, Movie(id:AnyObject)
	, Search(query:String, type:TraktType!, year:Int!)
	, Rate(TraktWatchable, Int)
	
	private var domain:String {
		switch self {
		default:
			return "https://api-v2launch.trakt.tv"
		}
	}
	
	private var method:String {
		switch self {
		case .Token, .addToHistory, .removeFromHistory, .addToWatchlist, .Rate:
			return "POST"
        case .HideRecommendation:
            return "DELETE"
		default:
			return "GET"
		}
	}

	private var headers:[String:String]? {
		switch self {
		default:
			return nil
		}
	}
	
	private var path:String {
		switch self {
        case .Token:							return "/oauth/token"
        case .TrendingMovies:					return "/movies/trending"
        case .TrendingShows:					return "/shows/trending"
        case .RecommandationsMovies:			return "/recommendations/movies"
		case .Movie(let id):					return "/movies/\(id)"
		case .Episode(let showId, let season, let episode):
												return "/shows/\(showId)/seasons/\(season)/episodes/\(episode)"
		case .Collection(let type):				return "/sync/collection/\(type.rawValue)"
		case .Watchlist(let type):				return "/sync/watchlist/\(type.rawValue)"
        case .Watched(let type):				return "/sync/watched/\(type.rawValue)"
        case .Progress(let id):					return "/shows/\(id)/progress/watched"
        case .People(let type, let id):			return "/\(type.rawValue)/\(id)/people"
		case .addToHistory:						return "/sync/history"
		case .removeFromHistory:				return "/sync/history/remove"
		case .addToWatchlist:					return "/sync/watchlist"
		case .Search:							return "/search"
		case .Rate:								return "/sync/ratings"

        case .HideRecommendation(let movie):    return "/recommendations/movies/\(movie.id!)"
		}
	}
	
	private var parameters:[String:AnyObject]! {
		switch self {
		case .Token(let trakt, let pin):
			return [
				"code": pin,
				"client_id": trakt.clientId,
				"client_secret": trakt.clientSecret,
				"redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
				"grant_type": "authorization_code"
			]
		case .Watchlist, .Collection, .Progress, .Episode, .Movie, .People:
			return ["extended": "full,images"]

		case .TrendingMovies, .TrendingShows, .RecommandationsMovies:
			return ["extended": "full,images", "limit": "100"]

        case .addToWatchlist(let objects):
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

		case .addToHistory(let objects):
			var p:[String:[[String:AnyObject]]] = [:]
			for object in objects {
				if let id = object.ids[TraktId.Trakt] as? Int {

					if p[object.type!.rawValue] == nil {
						p[object.type!.rawValue] = []
					}
					p[object.type!.rawValue]?.append(["ids": ["trakt": id]])
				}
			}
			return p

		case .removeFromHistory(let objects):
			var p:[String:[[String:AnyObject]]] = [:]
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
			var p:[String:AnyObject] = [
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

			var p:[String: [AnyObject]] = [:]
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
	
	///
	public var URLRequest:NSMutableURLRequest {
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
			case .Token, .addToHistory, .removeFromHistory, .addToWatchlist, .Rate:
				let encoding = Alamofire.ParameterEncoding.JSON
				return encoding.encode(URLRequest, parameters: parameters).0
			default:
				let encoding = Alamofire.ParameterEncoding.URL
				return encoding.encode(URLRequest, parameters: parameters).0
			}
		}
		print("url failed for \(path)")
		return NSMutableURLRequest(URL: NSURL(string: "http://localhost")!)
	}
	
	func OAuthRequest(trakt:Trakt) -> NSURLRequest {
		let req = URLRequest.mutableCopy() as! NSMutableURLRequest
		req.setValue("2", forHTTPHeaderField: "trakt-api-version")
		req.setValue(trakt.clientId, forHTTPHeaderField: "trakt-api-key")
		if let token = trakt.token {
			req.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
		}
		return req
	}
}