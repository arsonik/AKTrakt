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

	public func watched(objects: [TraktWatchable]) -> Request {
		objects.forEach {
			$0.watched = true
		}
		return query(.AddToHistory(objects)) { response in
			/*
			if let item = response.result.value as? [String: AnyObject], added = item["added"] as? [String: Int], n = added[object.type!.rawValue] where n > 0 {
			completion(true, nil)
			} else {
			completion(false, response.result.error)
			}*/
			print(response.result.value)
		}
	}

	public func unWatch(objects: [TraktWatchable]) -> Request {
		return query(.RemoveFromHistory(objects)) { response in
			print(response.result.value)
		}
	}

	public func hideFromRecommendations(object: TraktWatchable, completion: ((Bool, NSError?) -> Void)? = nil) -> Request {
		return query(.HideRecommendation(object)) { response in
			completion?((response.response?.statusCode == 204) ?? false, response.result.error)
		}
	}

	public func addToWatchlist(objects: TraktWatchable...) -> Request {
		return query(.AddToWatchlist(objects)) { response in
			print(response.result.value)
		}
	}

	public func people(object: TraktWatchable, completion: ((succeed: Bool, error: NSError?) -> Void)) -> Request {
		return query(.People(object.type!, object.id!)) { response in
			if let result = response.result.value as? [String: AnyObject] {
				if let castData = result["cast"] as? [[String: AnyObject]] {
					let data = castData.flatMap {
						TraktCharacter(data: $0)
					}
					(object as? TraktShow)?.casting = data
					(object as? TraktMovie)?.casting = data
				}
				// possible keys: production, art, crew, costume & make-up, directing, writing, sound, and camera
				if let crewData = result["crew"] as? [String: [[String: AnyObject]]] {
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
			var list: [TraktWatchable]? = nil
			if let entries = response.result.value as? [[String: AnyObject]] {
				list = []
				for entry in entries {
					if let t = entry["type"] as? String, v = entry[t] as? [String: AnyObject] where type.single == t {
						switch type {
						case .Movies:
							if let a = TraktMovie(data: v) {
								list!.append(a)
							} else {
								print("Failed TraktMovie\(v)")
							}
						case .Shows:
							if let show = TraktShow(data: v) {
								list!.append(show)
							} else {
								print("Failed TraktShow\(v)")
							}
						default:
							print("Not handled \(type)")
						}
					}
				}
			}
			completion(result: list, error: nil)
		}
	}

	public func watched(type: TraktType, completion: ((result: [TraktWatchable]?, error: NSError?) -> Void)) -> Request {
		return query(.Watched(type)) { response in
			var list: [TraktWatchable]? = nil
			if let entries = response.result.value as? [[String: AnyObject]] {
				list = []
				for entry in entries {
					if let v = entry[type.single] as? [String: AnyObject] {
						switch type {
						case .Movies:
							if let a = TraktMovie(data: v) {
								list!.append(a)
							} else {
								print("Failed TraktMovie\(v)")
							}
						case .Shows:
							if let show = TraktShow(data: v) {
								list!.append(show)
							} else {
								print("Failed TraktShow\(v)")
							}
						default:
							print("Not handled \(type)")
						}
					}
				}
			}
			completion(result: list, error: nil)
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

	public func searchMovie(id: AnyObject, completion: (TraktMovie?, NSError?) -> Void) -> Request {
		return query(.Movie(id: id)) { response in
			// Todo: should not create a new object, complete the object instead
			if let item = response.result.value as? [String: AnyObject], o = TraktMovie(data: item) {
				completion(o, nil)
			} else {
				completion(nil, response.result.error)
			}
		}
	}

	public func searchEpisode(id: AnyObject, season: Int, episode: Int, completion: (TraktEpisode?, NSError?) -> Void) -> Request {
		return query(.Episode(showId: id, season: season, episode: episode)) { response in
			if let item = response.result.value as? [String: AnyObject], o = TraktEpisode(data: item) {
				completion(o, nil)
			} else {
				completion(nil, response.result.error)
			}
		}
	}

	public func episode(episode: TraktEpisode, completion: (loaded: Bool) -> Void) -> Request? {
		if episode.loaded == false {
			episode.loaded = nil
			return query(.Episode(showId: episode.season.show.id!, season: episode.season.number, episode: episode.number)) { response in
				guard let data = response.result.value as? JSONHash else {
					// cancelled
					if response.result.error?.code == NSURLErrorCancelled {
						episode.loaded = false
					} else {
						print("Cannot load episode \(episode) \(response.result.error) \(response.result.value)")
					}
					return completion(loaded: episode.loaded != nil && episode.loaded == true)
				}

				episode.title = data["title"] as? String
				episode.overview = data["overview"] as? String
				if let ids = TraktId.extractIds(data) {
					episode.ids = ids
				}
				(data["images"] as? [String: [String: String]])?.forEach { t, l in
					if let type = TraktImageType(rawValue: t) {
						for (s, uri) in l {
							if let size = TraktImageSize(rawValue: s) {
								if episode.images[type] == nil {
									episode.images[type] = [:]
								}
								episode.images[type]![size] = uri
							}
						}
					}
				}

				if let fa = data["first_aired"] as? String {
					episode.firstAired = self.dateFormatter.dateFromString(fa)
				}
				episode.loaded = true
				completion(loaded: episode.loaded != nil && episode.loaded == true)
			}
		} else {
			completion(loaded: episode.loaded != nil && episode.loaded == true)
		}
		return nil
	}

	public func progress(show: TraktShow, completion: ((loaded: Bool, error: NSError?) -> Void)) -> Request {
		return query(.Progress(show.id!)) { response in
			var loaded: Bool = false

			if let data = response.result.value as? [String: AnyObject], seasons = data["seasons"] as? [[String: AnyObject]] {
				for season in seasons {
					if let ms = TraktSeason(data: season), episodes = season["episodes"] as? [[String: AnyObject]] {
						ms.show = show
						for episode in episodes {
							if let ep = TraktEpisode(data:episode) {
								ep.season = ms
								ep.seasonNumber = ms.number
								ms.episodes.append(ep)
							}
						}
						show.seasons.append(ms)
						loaded = true
					}
				}
			}
			completion(loaded: loaded, error: nil)
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
}
