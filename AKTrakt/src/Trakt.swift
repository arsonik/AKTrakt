//
//  Trakt.swift
//  Arsonik
//
//  Created by Florian Morello on 08/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire
import Async


class Trakt {
	let clientId:String
	let clientSecret:String
    var token:TraktToken?
    let manager:Manager
    let applicationId: Int
	
    init(clientId:String, clientSecret:String, applicationId: Int = 3695){
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
    
    func exchangePinForToken(pin:String, completion:(Bool, NSError?) -> Void) {
        let request = TraktRoute.Token(client: self, pin: pin)
        manager.request(request).responseJSON { (response) -> Void in
            if let aToken = TraktToken(data: response.result.value as? [String:AnyObject]) {
                self.token = aToken
                completion(true, nil)
            }
            else{
                UIAlertView(title: "", message: "Failed to get a valid token", delegate: nil, cancelButtonTitle: "OK").show()
                print(response.result.error)
                //self.initWebview()
            }
        }
    }

    func clearToken() {
        token = nil
        saveTokenToDefaults(token: nil)
    }
	
	func saveTokenToDefaults(token t:TraktToken!) {
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

    func watched(objects:[TraktObject]){
		manager.request(TraktRoute.addToHistory(objects).OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.watched(objects)
                }
            }
		}
    }

    func unWatch(objects: [TraktObject]){
        manager.request(TraktRoute.removeFromHistory(objects).OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.unWatch(objects)
                }
            }
        }
    }

    func hideFromRecommendations(movie: TraktMovie){
        manager.request(TraktRoute.HideRecommendation(movie).OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.hideFromRecommendations(movie)
                }
            }
        }
    }

    func addToWatchlist(objects: TraktObject...) {
        manager.request(TraktRoute.addToWatchlist(objects).OAuthRequest(self)).responseJSON { (response) -> Void in
            ()
        }
    }

    func people(movie:TraktMovie) {
        manager.request(TraktRoute.People(movie.id!).OAuthRequest(self)).responseJSON { (response) -> Void in
            if let result = response.result.value as? [String:AnyObject] {
                if let castData = result["cast"] as? [[String:AnyObject]] {
                    var cast:[TraktCharacter] = []
                    for pip in castData {
                        if let people = TraktCharacter(data: pip) {
                            cast.append(people)
                        }
                    }
                }
                if let crewData = result["crew"] as? [String:[[String:AnyObject]]] {
                    var crew:[TraktCrew] = []
                    for (_, pips) in crewData {
                        for pip in pips {
                            if let people = TraktCrew(data: pip) {
                                crew.append(people)
                            }
                        }
                    }
                }

            }
        }
    }

	func watchList(type:TraktType, completion:((result:[TraktObject]?, error:NSError?) -> Void)){
		manager.request(TraktRoute.Watchlist(type).OAuthRequest(self)).responseJSON { (response) -> Void in
			var list:[TraktObject]? = nil
			if let entries = response.result.value as? [[String:AnyObject]] {
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

	func watched(type:TraktType, completion:((result:[TraktObject]?, error:NSError?) -> Void)){
		manager.request(TraktRoute.Watched(type).OAuthRequest(self)).responseJSON { (response) -> Void in
			var list:[TraktObject]? = nil
			if let entries = response.result.value as? [[String:AnyObject]] {
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
	
	func collection(type:TraktType, completion:((result:[TraktObject]!, error:NSError?) -> Void)) -> Request {
		return manager.request(TraktRoute.Collection(type).OAuthRequest(self)).responseJSON { (response) -> Void in
			var list:[TraktObject]! = nil
			if let entries = response.result.value as? [[String:AnyObject]] {
				list = []
				for entry in entries {
					if let sh = entry["show"] as? [String:AnyObject], o = TraktShow(data: sh) where type == TraktType.Shows {
						list.append(o)
					}
				}
			}
			else{
			}
			completion(result: list, error: nil)
		}
    }

    func trendingMovies(completion: ([TraktMovie]?, NSError?) -> Void) -> Request {
        return manager.request(TraktRoute.TrendingMovies.OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.trendingMovies(completion)
                }
            }
            if let entries = response.result.value as? [[String:AnyObject]] {
                var list:[TraktMovie] = []
                for entry in entries {
                    if let sh = entry["movie"] as? [String:AnyObject], o = TraktMovie(data: sh) {
                        list.append(o)
                    }
                }
                completion(list, response.result.error)
            }
            else {
                completion(nil, response.result.error)
            }
        }
    }

    func recommendationsMovies(completion: ([TraktMovie]?, NSError?) -> Void) -> Request {
        return manager.request(TraktRoute.RecommandationsMovies.OAuthRequest(self)).responseJSON { (response) -> Void in
            if let r = response.response where r.shouldRetry {
                return delay(5) {
                    self.recommendationsMovies(completion)
                }
            }
            if let entries = response.result.value as? [[String:AnyObject]] {
                var list:[TraktMovie] = []
                for entry in entries {
                    if let o = TraktMovie(data: entry) {
                        list.append(o)
                    }
                }
                completion(list, response.result.error)
            }
            else {
                completion(nil, response.result.error)
            }
        }
    }
	
	private lazy var dateFormatter:NSDateFormatter = {
		let df = NSDateFormatter()
		df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
		df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
		return df
	}()
	
	func episode(episode:TraktEpisode, completion:((loaded:Bool) -> Void)) -> Request? {
		if let ld = episode.loaded where ld == false {
			episode.loaded = nil
			return manager.request(TraktRoute.Episode(showId: episode.season.show.id!, season: episode.season.number, episode: episode.number).OAuthRequest(self)).responseJSON { (response) -> Void in
				if let data = response.result.value as? [String:AnyObject], title = data["title"] as? String, overview = data["overview"] as? String {
					episode.title = title
					episode.overview = overview
					if let ids = TraktId.extractIds(data) {
						episode.ids = ids
					}
					if let im = data["images"] as? [String:[String:String]] {
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
	
	func progress(show:TraktShow, completion:((loaded:Bool, error:NSError?) -> Void)){
		manager.request(TraktRoute.Progress(show.id!).OAuthRequest(self)).responseJSON { (response) -> Void in
			var loaded:Bool = false
            
			if let data = response.result.value as? [String:AnyObject], seasons = data["seasons"] as? [[String:AnyObject]] {
				for season in seasons {
					if let ms = TraktSeason(data: season), episodes = season["episodes"] as? [[String:AnyObject]] {
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
	
	
	var searchOperationQueue:NSOperationQueue = NSOperationQueue()
	/*
	func search(item:WatchableItem, completion:((results:[TraktObject]?, error:NSError?) -> Void)) -> NSOperation {
		let op = NSBlockOperation()
		op.addExecutionBlock {[weak op] () -> Void in
			// it s an episode
			if let sn = item.seasonNumber, en = item.episodeNumber {
				self.manager.request(TraktRoute.Episode(showId: item.title.slug, season: sn, episode: en).OAuthRequest(self)).responseJSON { (response) -> Void in
					if op?.cancelled == true {
						return ()
					}
					if let episode = TraktEpisode(data: response.result.value as? [String:AnyObject]) {
						completion(results: [episode], error: response.result.error)
					}
					else{
						// failed > search
						self.search(item.title, completion: { (results, error) -> Void in
							completion(results: results, error: error)
						})
					}
				}
			}
			// movie
			else{
				var id:String = item.title.slug
				if let yr = item.year {
					id += "-\(yr)"
				}
				// try to load movie with slug
				self.manager.request(TraktRoute.Movie(id:id).OAuthRequest(self)).responseJSON { (response) -> Void in
					if op?.cancelled == true {
						return ()
					}
					if let movie = TraktMovie(data: response.result.value as? [String:AnyObject]) {
						completion(results: [movie], error: nil)
					}
					else{
						print("cannot find movie \(item)")
						// failed > search
						self.search(item.title, type: TraktType.Movies, year: item.year, completion: { (results, error) -> Void in
							completion(results: results, error: error)
						})
					}
				}
			}
		}
		searchOperationQueue.addOperation(op)
		return op
	}
	*/
	func search(query:String, type:TraktType! = nil, year:Int! = nil, completion:((results:[TraktObject]?, error:NSError?) -> Void)) -> Request {
		return manager.request(TraktRoute.Search(query: query, type: type, year: year).OAuthRequest(self)).responseJSON { (response) -> Void in
			var list:[TraktObject]?
			if let items = response.result.value as? [[String:AnyObject]] {
				list = []
				for item in items {
					if let o = TraktObject.autoload(item) {
						list!.append(o)
					}
				}
			}
			completion(results: list, error: response.result.error)
		}
	}
}





