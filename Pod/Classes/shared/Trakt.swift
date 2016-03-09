//
//  Trakt.swift
//  Arsonik
//
//  Created by Florian Morello on 08/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

public class Trakt {
	internal let clientId: String
    internal let clientSecret: String
    internal let applicationId: Int
    internal var token: TraktToken?
	internal var retryInterval: Double = 5
	private var attempts = NSCache()
	internal var maximumAttempt: Int = 5
    private let manager: Manager

    public init(clientId: String, clientSecret: String, applicationId: Int) {
		self.clientId = clientId
		self.clientSecret = clientSecret
        self.applicationId = applicationId

        manager = Manager()

        // autoload token
        if let td = tokenFromDefaults() {
            token = td
        }
    }

	private func tokenFromDefaults() -> TraktToken? {
		let defaults = NSUserDefaults.standardUserDefaults()
		guard let at = defaults.objectForKey("trakt_access_token_\(clientId)") as? String,
			ex = defaults.objectForKey("trakt_expire_\(clientId)") as? NSDate,
			rt = defaults.objectForKey("trakt_refresh_token_\(clientId)") as? String else {
			return nil
		}
		return TraktToken(accessToken: at, expire: ex, refreshToken: rt)
	}

    internal func exchangePinForToken(pin: String, completion: (TraktToken?, NSError?) -> Void) -> Request {
        return query(TraktRoute.Token(client: self, pin: pin)) { response in
            if let aToken = TraktToken(data: response.result.value as? [String: AnyObject]) {
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

    public func clearToken() {
        saveToken(nil)
    }

	public func saveToken(token: TraktToken!) {
        self.token = token
		let defaults = NSUserDefaults.standardUserDefaults()
        if token != nil {
            defaults.setObject(token.accessToken, forKey: "trakt_access_token_\(clientId)")
            defaults.setObject(token.expire, forKey: "trakt_expire_\(clientId)")
            defaults.setObject(token.refreshToken, forKey: "trakt_refresh_token_\(clientId)")
        } else {
            defaults.removeObjectForKey("trakt_access_token_\(clientId)")
            defaults.removeObjectForKey("trakt_expire_\(clientId)")
            defaults.removeObjectForKey("trakt_refresh_token_\(clientId)")
        }
	}

	private lazy var dateFormatter: NSDateFormatter = {
		let df = NSDateFormatter()
		df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
		df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
		return df
	}()


	private func query(route: TraktRoute, completionHandler: Response<AnyObject, NSError> -> Void) -> Request {
		let key = "\(route.hashValue)"
		return manager.request(route.needAuthorization() ? route.OAuthRequest(self) : route).responseJSON { [weak self] response in
			if let interval = self?.retryInterval where response.response?.statusCode >= 500 {
				var attempt: Int = self?.attempts.objectForKey(key) as? Int ?? 1
				self?.attempts.setValue(++attempt, forKey: key)
				if attempt < self!.maximumAttempt {
					return delay(interval) {
						self?.query(route, completionHandler: completionHandler)
					}
				} else {
					print("Maximum attempt reached for request \(route)")
				}
			}
			self?.attempts.removeObjectForKey(key)
			completionHandler(response)
		}
	}

    public func watched(objects: [TraktWatchable]) -> Request {
		objects.forEach {
			$0.watched = true
		}
		return query(TraktRoute.AddToHistory(objects)) { response in
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
		return query(TraktRoute.RemoveFromHistory(objects)) { response in
			print(response.result.value)
        }
    }

    public func hideFromRecommendations(movie: TraktMovie) -> Request {
		return query(TraktRoute.HideRecommendation(movie)) { response in
			print(response.result.value)
        }
    }

    public func addToWatchlist(objects: TraktWatchable...) -> Request {
		return query(TraktRoute.AddToWatchlist(objects)) { response in
			print(response.result.value)
        }
    }

    public func people(object: TraktWatchable, completion: ((succeed: Bool, error: NSError?) -> Void)) -> Request {
        return query(TraktRoute.People(object.type!, object.id!)) { response in
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
        return query(TraktRoute.Credits(person.id!, type)) { response in
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
		return query(TraktRoute.Watchlist(type)) { response in
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
		return query(TraktRoute.Watched(type)) { response in
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
		return query(TraktRoute.Collection(type)) { response -> Void in
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

	public func trending(type: TraktType, completion: ([TraktWatchable]?, NSError?) -> Void) -> Request {
		return query(TraktRoute.Trending(type)) { response in
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

	public func recommendations(type: TraktType, completion: ([TraktWatchable]?, NSError?) -> Void) -> Request {
        return query(TraktRoute.Recommandations(type)) { response in
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
		return query(TraktRoute.Rate(object, rate)) { response in
			if let item = response.result.value as? [String: AnyObject], added = item["added"] as? [String: Int], n = added[object.type!.rawValue] where n > 0 {
				completion(true, nil)
			} else {
				completion(false, response.result.error)
			}
		}
	}

    public func searchMovie(id: AnyObject, completion: (TraktMovie?, NSError?) -> Void) -> Request {
        return query(TraktRoute.Movie(id: id)) { response in
            // Todo: should not create a new object, complete the object instead
            if let item = response.result.value as? [String: AnyObject], o = TraktMovie(data: item) {
                completion(o, nil)
            } else {
                completion(nil, response.result.error)
            }
        }
    }

	public func searchEpisode(id: AnyObject, season: Int, episode: Int, completion: (TraktEpisode?, NSError?) -> Void) -> Request {
		//print("serch ep \(id), \(season), \(episode)")
		return query(TraktRoute.Episode(showId: id, season: season, episode: episode)) { response in
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
			return query(TraktRoute.Episode(showId: episode.season.show.id!, season: episode.season.number, episode: episode.number)) { response in
				guard let data = response.result.value as? [String: AnyObject], title = data["title"] as? String, overview = data["overview"] as? String else {
					// cancelled
					if response.result.error?.code == -999 {
						episode.loaded = false
					} else {
						print("Cannot load episode \(episode) \(response.result.error)")
					}
					return completion(loaded: episode.loaded != nil && episode.loaded == true)
				}

				episode.title = title
				episode.overview = overview
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
		return query(TraktRoute.Progress(show.id!)) { response in
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

	public func search(query: String, type: TraktType! = nil, year: Int! = nil, completion: ((results: [TraktObject]?, error: NSError?) -> Void)) -> Request {
		return self.query(TraktRoute.Search(query: query, type: type, year: year)) { response in
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
}
