//
//  Trakt+Queries.swift
//  Pods
//
//  Created by Florian Morello on 11/03/16.
//
//

import Foundation
import Alamofire

extension Trakt {

	internal func exchangePinForToken(pin: String, completion: (TraktToken?, NSError?) -> Void) -> Request {
		return query(.Token(client: self, pin: pin)) { response in
			if let aToken = TraktToken(data: response.result.value as? JSONHash) {
				completion(aToken, nil)
			} else {
				let err: NSError?
				if let error = (response.result.value as? [String: AnyObject])?["error_description"] as? String {
					err = NSError(domain: "trakt.tv", code: 401, userInfo: [NSLocalizedDescriptionKey: error])
				} else {
					err = response.result.error
				}
				completion(nil, err)
			}
		}
	}
	
	public func generateCode(completion: (GeneratedCodeResponse?, NSError?) -> Void) -> Request {
		return query(.GenerateCode(clientId: clientId)) { response in
			guard
				let data = response.result.value as? JSONHash,
				deviceCode = data["device_code"] as? String,
				userCode = data["user_code"] as? String,
				verificationUrl = data["verification_url"] as? String,
				expiresIn = data["expires_in"] as? Double,
				interval = data["interval"] as? Double
				else {
					return completion(nil, response.result.error)
			}
			completion((deviceCode: deviceCode, userCode: userCode, verificationUrl: verificationUrl, expiresAt: NSDate().dateByAddingTimeInterval(expiresIn), interval: interval), nil)
		}
	}

	public func pollDevice(response: GeneratedCodeResponse, completion: (TraktToken?, NSError?) -> Void) -> Request {
		return query(.PollDevice(deviceCode: response.deviceCode, clientId: clientId, clientSecret: clientSecret)) { response in
			completion(TraktToken(data: response.result.value as? JSONHash), response.result.error)
		}
	}

	public func watched(object: TraktWatchable, completion: ((Bool, NSError?) -> Void)) -> Request {
		return query(.AddToHistory([object])) { response in
			if let item = response.result.value as? JSONHash, added = item["added"] as? [String: Int], n = added[object.type!.rawValue] where n > 0 {
				object.watched = true
				completion(true, nil)
			} else {
				completion(false, response.result.error)
			}
		}
	}

	public func unWatch(object: TraktWatchable, completion: ((Bool, NSError?) -> Void)) -> Request {
		return query(.RemoveFromHistory([object])) { response in
			if let item = response.result.value as? JSONHash, added = item["deleted"] as? [String: Int], n = added[object.type!.rawValue] where n > 0 {
				object.watched = false
				completion(true, nil)
			} else {
				completion(false, response.result.error)
			}
		}
	}

	public func hideFromRecommendations(object: TraktWatchable, completion: ((Bool, NSError?) -> Void)? = nil) -> Request {
		return query(.HideRecommendation(object)) { response in
			completion?((response.response?.statusCode == 204) ?? false, response.result.error)
		}
	}

	public func addToWatchlist(object: TraktWatchable, completion: ((Bool, NSError?) -> Void)) -> Request {
		return query(.AddToWatchlist([object])) { response in
			if let result = response.result.value as? JSONHash,
				added = result["added"] as? [String: Int],
				type = object.type?.rawValue,
				success = added[type]
				where success == 1 {
				object.watchlist = true
				completion(true, nil)
			} else {
				completion(false, response.result.error)
			}
		}
	}

	public func removeFromWatchlist(object: TraktWatchable, completion: ((Bool, NSError?) -> Void)) -> Request {
		return query(.RemoveFromWatchlist([object])) { response in
			if let result = response.result.value as? JSONHash,
				added = result["deleted"] as? [String: Int],
				type = object.type?.rawValue,
				success = added[type]
				where success == 1 {
				object.watchlist = false
				completion(true, nil)
			} else {
				completion(false, response.result.error)
			}
		}
	}

	public func people(object: TraktWatchable, completion: ((succeed: Bool, error: NSError?) -> Void)) -> Request {
		return query(.People(object.type!, object.id!)) { response in
			if let result = response.result.value as? JSONHash {
				if let castData = result["cast"] as? [JSONHash] {
					let data = castData.flatMap {
						TraktCharacter(data: $0)
					}
					(object as? TraktShow)?.casting = data
					(object as? TraktMovie)?.casting = data
				}
				// possible keys: production, art, crew, costume & make-up, directing, writing, sound, and camera
				if let crewData = result["crew"] as? [String: [JSONHash]] {
					let data = crewData.values.flatMap({$0}).flatMap {
						TraktCrew(data: $0)
					}
					(object as? TraktShow)?.crew = data
					(object as? TraktMovie)?.crew = data
				}
				completion(succeed: true, error: response.result.error)
			} else {
				completion(succeed: false, error: response.result.error)
			}
		}
	}

	public func credits(person: TraktPerson, type: TraktType, completion: ((result: [TraktWatchable]?, error: NSError?) -> Void)) -> Request {
		return query(.Credits(person.id!, type)) { response in
			if let result = response.result.value as? [String: AnyObject] {
				var list: Set<TraktWatchable> = []
				if let crew = result["crew"] as? [String: [[String: AnyObject]]] {
					crew.flatMap({
						return $0.1.flatMap({
							guard let item = $0[type.single] as? [String: AnyObject] else {
								return nil
							}
							return type == .Movies ? TraktMovie(data: item) : TraktShow(data: item)
						})
					}).forEach({
						list.insert($0)
					})
				}
				if let cast = result["cast"] as? [[String: AnyObject]] {
					cast.flatMap({
						guard let item = $0[type.single] as? [String: AnyObject] else {
							return nil
						}
						return type == .Movies ? TraktMovie(data: item) : TraktShow(data: item)
					}).forEach({
						list.insert($0)
					})
				}
				completion(result: Array(list), error: response.result.error)
			}
		}
	}

	public func watchList(type: TraktType, completion: ((result: [TraktWatchable]?, error: NSError?) -> Void)) -> Request {
		return query(.Watchlist(type)) { response in
			let list: [TraktWatchable]? = (response.result.value as? [JSONHash])?.flatMap { entry in
				guard let t = entry["type"] as? String, v = entry[t] as? JSONHash else {
					return nil
				}
				switch type {
				case .Movies:
					return TraktMovie(data: v)
				case .Shows:
					return TraktShow(data: v)
				default:
					print("Not handled \(type)")
				}
				return nil
			}
			list?.forEach {
				$0.watchlist = true
			}
			completion(result: list, error: nil)
		}
	}

	public typealias WatchedReturn = (object: TraktWatchable, plays: Int, lastWatchedAt: NSDate)

	public func watched(type: TraktType, completion: (([WatchedReturn]?, NSError?) -> Void)) -> Request {
		return query(.Watched(type)) { response in
			guard let data = (response.result.value as? [JSONHash]) else {
				return completion(nil, response.result.error)
			}

			let list: [WatchedReturn]? = data.flatMap { entry in
				guard let objectData = entry[type.single] as? JSONHash,
					plays = entry["plays"] as? Int,
					lastAt = entry["last_watched_at"] as? String,
					lastWatchedAt = self.dateFormatter.dateFromString(lastAt) else {
						print(response.result.error)
						return nil
				}

				let object: TraktWatchable?
				switch type {
				case .Movies:
					object = TraktMovie(data: objectData)
				case .Shows:
					object = TraktShow(data: objectData)
				default:
					fatalError("Not handled \(type)")
				}
				if object != nil {
					return (object: object!, plays: plays, lastWatchedAt: lastWatchedAt)
				} else {
					return nil
				}
			}
			list?.forEach {
				$0.object.watched = true
			}
			completion(list, nil)
		}
	}

	public func collection(type: TraktType, completion: ((result: [TraktWatchable]?, error: NSError?) -> Void)) -> Request {
		return query(.Collection(type)) { response -> Void in
			if let entries = response.result.value as? [[String: AnyObject]] {
				let list: [TraktWatchable] = entries.flatMap({
					if type == .Shows {
						return TraktShow(data: $0[type.single] as? [String: AnyObject])
					} else if type == .Movies {
						return TraktMovie(data: $0[type.single] as? [String: AnyObject])
					} else {
						return nil
					}
				})
				completion(result: list, error: nil)
			} else {
				completion(result: nil, error: response.result.error)
			}
		}
	}

	public func trending(type: TraktType, pagination: TraktPagination! = nil, completion: ([TraktWatchable]?, NSError?) -> Void) -> Request {
		return query(.Trending(type, pagination ?? TraktPagination(page: 1, limit: 100))) { response in
			if let entries = response.result.value as? [[String: AnyObject]] {
				let list: [TraktWatchable] = entries.flatMap({
					if type == .Movies {
						return TraktMovie(data: $0[type.single] as? [String: AnyObject])
					} else if type == .Shows {
						return TraktShow(data: $0[type.single] as? [String: AnyObject])
					} else {
						return nil
					}
				})
				completion(list, response.result.error)
			} else {
				completion(nil, response.result.error)
			}
		}
	}

	public func recommendations(type: TraktType, pagination: TraktPagination! = nil, completion: ([TraktWatchable]?, NSError?) -> Void) -> Request {
		return query(.Recommandations(type, pagination ?? TraktPagination(page: 1, limit: 100))) { response in
			if let entries = response.result.value as? [[String: AnyObject]] {
				let list: [TraktWatchable] = entries.flatMap({
					if type == .Movies {
						return TraktMovie(data: $0)
					} else if type == .Shows {
						return TraktShow(data: $0)
					} else {
						return nil
					}
				})
				completion(list, response.result.error)
			} else {
				completion(nil, response.result.error)
			}
		}
	}

	public func rate(object: TraktWatchable, rate: Int, completion: (Bool, NSError?) -> Void) -> Request {
		return query(.Rate(object, rate)) { response in
			if let item = response.result.value as? [String: AnyObject], added = item["added"] as? [String: Int], n = added[object.type!.rawValue] where n > 0 {
				completion(true, nil)
			} else {
				completion(false, response.result.error)
			}
		}
	}

	public func searchMovie(id: String, completion: (TraktMovie?, NSError?) -> Void) -> Request {
		return query(.Movie(id: id)) { response in
			guard let item = response.result.value as? [String: AnyObject], o = TraktMovie(data: item) else {
				print("Cannot find movie \(id)")
				return completion(nil, response.result.error)
			}
			completion(o, nil)
		}
	}
    
    public func searchShow(id: String, completion: (TraktShow?, NSError?) -> Void) -> Request {
        return query(.Show(id: id)) { response in
            guard let item = response.result.value as? [String: AnyObject], o = TraktShow(data: item) else {
                print("Cannot find show \(id)")
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }

	public func searchEpisode(id: AnyObject, season: Int, episode: Int, completion: (TraktEpisode?, NSError?) -> Void) -> Request {
		return query(.Episode(showId: id, season: season, episode: episode)) { response in
			guard let item = response.result.value as? [String: AnyObject], o = TraktEpisode(data: item) else {
				print("Cannot find episode \(id)")
				return completion(nil, response.result.error)
			}
			completion(o, nil)
		}
	}

	public func episode(episode: TraktEpisode, completion: (Bool, NSError?) -> Void) -> Request? {
		if episode.loaded != nil && episode.loaded == false {
			episode.loaded = nil
			return query(.Episode(showId: episode.season!.show!.id!, season: episode.season!.number, episode: episode.number)) { response in
				guard let data = response.result.value as? JSONHash else {
					episode.loaded = false
					if response.result.error?.code != NSURLErrorCancelled {
						print("Cannot load episode \(episode) \(response.result.error) \(response.result.value)")
					}
					return completion(episode.loaded != nil && episode.loaded == true, response.result.error)
				}

				episode.digest(data)
				episode.loaded = true
				completion(true, nil)
			}
		} else {
			completion(episode.loaded != nil && episode.loaded == true, nil)
		}
		return nil
	}

	public func progress(show: TraktShow, completion: ((status: Bool, error: NSError?) -> Void)) -> Request {
		return query(.Progress(show)) { response in
			guard let data = response.result.value as? JSONHash else {
				return completion(status: false, error: response.result.error)
			}

			(data["seasons"] as? [JSONHash])?.forEach { seasonData in
				if let season = TraktSeason(data: seasonData), episodes = seasonData["episodes"] as? [JSONHash] {
					episodes.flatMap {
						var test = $0
						test["season"] = season.number
						return TraktEpisode(data: test)
					}.forEach {
						season.addEpisode($0)
					}
					show.addSeason(season)
				}
			}

			if let nxt = data["next_episode"] as? JSONHash, next = TraktEpisode(data: nxt) {
				show.nextEpisode = next
				if show.season(next.seasonNumber)?.episode(next.number) == nil {
					if let season = show.season(next.seasonNumber) {
						season.addEpisode(next)
					} else if let season = TraktSeason(data: ["number": next.seasonNumber]) {
						season.addEpisode(next)
						show.addSeason(season)
					}
				}
			}

			return completion(status: true, error: response.result.error)
		}
	}

	public func search(query: String, type: TraktType! = nil, year: Int! = nil, pagination: TraktPagination! = nil, completion: ((results: [TraktObject]?, error: NSError?) -> Void)) -> Request {
		return self.query(.Search(query: query, type: type, year: year, pagination ?? TraktPagination(page: 1, limit: 100))) { response in
			let list: [TraktObject]?
			if let items = response.result.value as? [[String: AnyObject]] {
				list = items.flatMap({
					TraktObject.autoload($0)
				})
			} else {
				list = nil
			}
			completion(results: list, error: response.result.error)
		}
	}

	public func profile(name: String!, completion: (JSONHash?, NSError?) -> Void) -> Request {
		return query(.Profile(name)) { response in
			completion(response.result.value as? JSONHash, response.result.error)
		}
	}

	public func releases(movie: TraktMovie, countryCode: String! = nil, completion: ([TraktRelease]?, NSError?) -> Void) -> Request {
		return query(.Releases(movie, countryCode: countryCode)) { response in
			if let data = response.result.value as? [JSONHash] {
				movie.releases = data.flatMap {
					TraktRelease(data: $0)
				}
				completion(movie.releases, response.result.error)
			} else {
				completion(nil, response.result.error)
			}
		}
	}
}
