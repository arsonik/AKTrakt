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
		if let at = defaults.objectForKey("trakt_access_token_\(clientId)") as? String, ex = defaults.objectForKey("trakt_expire_\(clientId)") as? NSDate, rt = defaults.objectForKey("trakt_refresh_token_\(clientId)") as? String {
			return TraktToken(accessToken: at, expire: ex, refreshToken: rt)
		}
		return nil
	}

    internal func exchangePinForToken(pin: String, completion: (TraktToken?, NSError?) -> Void) {
        let request = TraktRoute.Token(client: self, pin: pin)
        manager.request(request).responseJSON { response in
            if let aToken = TraktToken(data: response.result.value as? [String: AnyObject]) {
                completion(aToken, nil)
            }
            else {
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
        saveToken(token: nil)
    }

	public func saveToken(token t: TraktToken!) {
        token = t
		let defaults = NSUserDefaults.standardUserDefaults()
        if t != nil {
            defaults.setObject(t.accessToken, forKey: "trakt_access_token_\(clientId)")
            defaults.setObject(t.expire, forKey: "trakt_expire_\(clientId)")
            defaults.setObject(t.refreshToken, forKey: "trakt_refresh_token_\(clientId)")
        }
        else {
            defaults.removeObjectForKey("trakt_access_token_\(clientId)")
            defaults.removeObjectForKey("trakt_expire_\(clientId)")
            defaults.removeObjectForKey("trakt_refresh_token_\(clientId)")
        }
	}

    public func watched(objects: [TraktWatchable]) {
		objects.forEach {
			$0.watched = true
		}

		manager.request(TraktRoute.addToHistory(objects).OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.watched(objects)
                }
            }
			else {
				print(response.result.value)
			}
		}
    }

    public func unWatch(objects: [TraktWatchable]) {
        manager.request(TraktRoute.removeFromHistory(objects).OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.unWatch(objects)
                }
            }
        }
    }

    public func hideFromRecommendations(movie: TraktMovie) {
        manager.request(TraktRoute.HideRecommendation(movie).OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.hideFromRecommendations(movie)
                }
            }
        }
    }

    public func addToWatchlist(objects: TraktWatchable...) {
        manager.request(TraktRoute.addToWatchlist(objects).OAuthRequest(self)).responseJSON { (response) -> Void in
            ()
        }
    }

    public func people(movie: TraktMovie, completion: ((succeed: Bool, error: NSError?) -> Void)) {
        manager.request(TraktRoute.People(.Movies, movie.id!).OAuthRequest(self)).responseJSON { (response) -> Void in
            if let result = response.result.value as? [String: AnyObject] {
                if let castData = result["cast"] as? [[String: AnyObject]] {
                    movie.casting = castData.flatMap {
						TraktCharacter(data: $0)
                    }
                }
				// possible keys: production, art, crew, costume & make-up, directing, writing, sound, and camera
                if let crewData = result["crew"] as? [String: [[String: AnyObject]]] {
                    movie.crew = crewData.values.flatMap({$0}).flatMap {
                        TraktCrew(data: $0)
                    }
                }
                completion(succeed: true, error: response.result.error)
            } else {
                completion(succeed: false, error: response.result.error)
            }
        }
    }

    public func credits(person: TraktPerson, type: TraktType, completion: ((result: [TraktWatchable]?, error: NSError?) -> Void)) {
        manager.request(TraktRoute.Credits(person.id!, type).OAuthRequest(self)).responseJSON { (response) -> Void in
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

	public func watchList(type: TraktType, completion: ((result: [TraktObject]?, error: NSError?) -> Void)) {
		manager.request(TraktRoute.Watchlist(type).OAuthRequest(self)).responseJSON { (response) -> Void in
			var list: [TraktObject]? = nil
			if let entries = response.result.value as? [[String: AnyObject]] {
				list = []
				for entry in entries {
					if let t = entry["type"] as? String, v = entry[t] as? [String: AnyObject] where type.single == t {
						switch type {
						case .Movies:
							if let a = TraktMovie(data: v) {
								list!.append(a)
							}
							else{
								print("Failed TraktMovie\(v)")
							}
						case .Shows:
							if let show = TraktShow(data: v) {
								list!.append(show)
							}
							else{
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

	public func watched(type: TraktType, completion: ((result: [TraktObject]?, error: NSError?) -> Void)) {
		manager.request(TraktRoute.Watched(type).OAuthRequest(self)).responseJSON { (response) -> Void in
			var list: [TraktObject]? = nil
			if let entries = response.result.value as? [[String: AnyObject]] {
				list = []
				for entry in entries {
					if let v = entry[type.single] as? [String: AnyObject] {
						switch type {
						case .Movies:
							if let a = TraktMovie(data: v) {
								list!.append(a)
							}
							else{
								print("Failed TraktMovie\(v)")
							}
						case .Shows:
							if let show = TraktShow(data: v) {
								list!.append(show)
							}
							else{
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

	public func collection(type: TraktType, completion: ((result: [TraktObject]?, error: NSError?) -> Void)) -> Request {
		return manager.request(TraktRoute.Collection(type).OAuthRequest(self)).responseJSON { [weak self] response -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self?.collection(type, completion: completion)
                }
            } else if let entries = response.result.value as? [[String: AnyObject]] {
				let list: [TraktObject] = entries.flatMap({
					if type == .Shows {
						return TraktShow(data: $0["show"] as? [String: AnyObject])
					} else if type == .Movies {
						return TraktMovie(data: $0["movie"] as? [String: AnyObject])
					} else {
						return nil
					}
				})
                completion(result: list, error: nil)
			}
            else {
                completion(result: nil, error: response.result.error)
            }
		}
    }

    public func trendingMovies(completion: ([TraktMovie]?, NSError?) -> Void) -> Request {
        return manager.request(TraktRoute.TrendingMovies.OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.trendingMovies(completion)
                }
            }
			if let entries = response.result.value as? [[String: AnyObject]] {
				let list = entries.flatMap({
					TraktMovie(data: $0["movie"] as? [String: AnyObject])
				})
                completion(list, response.result.error)
            }
            else {
                completion(nil, response.result.error)
            }
        }
    }

    public func trendingShows(completion: ([TraktShow]?, NSError?) -> Void) -> Request {
        return manager.request(TraktRoute.TrendingShows.OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.trendingShows(completion)
                }
            }
            if let entries = response.result.value as? [[String: AnyObject]] {
				let list = entries.flatMap({
					TraktShow(data: $0["show"] as? [String: AnyObject])
				})
                completion(list, response.result.error)
            }
            else {
                completion(nil, response.result.error)
            }
        }
    }

    public func recommendationsMovies(completion: ([TraktMovie]?, NSError?) -> Void) -> Request {
        return manager.request(TraktRoute.RecommandationsMovies.OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.recommendationsMovies(completion)
                }
            }
            if let entries = response.result.value as? [[String: AnyObject]] {
				let list = entries.flatMap({
					TraktMovie(data: $0)
				})
                completion(list, response.result.error)
            }
            else {
                completion(nil, response.result.error)
            }
        }
    }

	public func rate(object: TraktWatchable, rate: Int, completion: (Bool?, NSError?) -> Void) -> Request {
		return manager.request(TraktRoute.Rate(object, rate).OAuthRequest(self)).responseJSON { (response) -> Void in
			if let item = response.result.value as? [String: AnyObject], added = item["added"] as? [String: Int], n = added[object.type!.rawValue] where n > 0 {
				completion(true, nil)
			}
			else {
				completion(false, response.result.error)
			}
		}
	}

	private lazy var dateFormatter: NSDateFormatter = {
		let df = NSDateFormatter()
		df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
		df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
		return df
	}()

    public func searchEpisode(id: AnyObject, season: Int, episode: Int, completion: (TraktEpisode?, NSError?) -> Void) -> Request {
        //print("serch ep \(id), \(season), \(episode)")
        return manager.request(TraktRoute.Episode(showId: id, season: season, episode: episode).OAuthRequest(self)).responseJSON { (response) -> Void in
            if let item = response.result.value as? [String: AnyObject], o = TraktEpisode(data: item) {
                completion(o, nil)
            }
            else {
                completion(nil, response.result.error)
            }
        }
    }

    public func searchMovie(id: AnyObject, completion: (TraktMovie?, NSError?) -> Void) -> Request {
        return manager.request(TraktRoute.Movie(id: id).OAuthRequest(self)).responseJSON { (response) -> Void in
            // Todo: should not create a new object, complete the object instead
            if let item = response.result.value as? [String: AnyObject], o = TraktMovie(data: item) {
                completion(o, nil)
            }
            else {
                completion(nil, response.result.error)
            }
        }
    }

	public func episode(episode: TraktEpisode, completion: ((loaded: Bool) -> Void)) -> Request? {
		if let ld = episode.loaded where ld == false {
			episode.loaded = nil
			return manager.request(TraktRoute.Episode(showId: episode.season.show.id!, season: episode.season.number, episode: episode.number).OAuthRequest(self)).responseJSON { (response) -> Void in
				if let data = response.result.value as? [String: AnyObject], title = data["title"] as? String, overview = data["overview"] as? String {
					episode.title = title
					episode.overview = overview
					if let ids = TraktId.extractIds(data) {
						episode.ids = ids
					}
					if let im = data["images"] as? [String: [String: String]] {
						for (t, l) in im {
							if let type = TraktImageType(rawValue: t) {
								for (s,uri) in l {
									if let size = TraktImageSize(rawValue: s) {
										if episode.images[type] == nil {
											episode.images[type] = [:]
										}
										episode.images[type]![size] = uri
									}
								}
							}
						}
					}
					if let fa = data["first_aired"] as? String {
						episode.firstAired = self.dateFormatter.dateFromString(fa)
					}
					episode.loaded = true
				}
				else{
					// cancelled
					if response.result.error?.code == -999 {
						episode.loaded = false
					}
					else{
						print("Cannot load episode \(episode) \(response.result.error)")
					}
				}
				completion(loaded: episode.loaded != nil && episode.loaded == true)
			}
		}
		else {
			completion(loaded: episode.loaded != nil && episode.loaded == true)
		}
		return nil
	}

	public func progress(show: TraktShow, completion: ((loaded: Bool, error: NSError?) -> Void)) {
		manager.request(TraktRoute.Progress(show.id!).OAuthRequest(self)).responseJSON { (response) -> Void in
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

	var searchOperationQueue: NSOperationQueue = NSOperationQueue()

	public func search(query: String, type: TraktType! = nil, year: Int! = nil, completion: ((results: [TraktObject]?, error: NSError?) -> Void)) -> Request {
		return manager.request(TraktRoute.Search(query: query, type: type, year: year).OAuthRequest(self)).responseJSON { (response) -> Void in
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
