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
            guard let aToken = TraktToken(data: response.result.value as? JSONHash) else {
                let err: NSError?
                if let error = (response.result.value as? JSONHash)?["error_description"] as? String {
                    err = NSError(domain: "trakt.tv", code: 401, userInfo: [NSLocalizedDescriptionKey: error])
                } else {
                    err = response.result.error
                }
                return completion(nil, err)
            }

            completion(aToken, nil)
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
                interval = data["interval"] as? Double else {
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

    public func watched(object: protocol<TraktIdentifiable, Watchable>, completion: ((Bool, NSError?) -> Void)) -> Request {
        return query(.AddToHistory([object])) { response in
            guard let item = response.result.value as? JSONHash, added = item["added"] as? [String: Int], n = added[object.type.rawValue] where n > 0 else {
                return completion(false, response.result.error)
            }

            object.watched = true
            completion(true, nil)
        }
    }

    public func unWatch(object: protocol<TraktIdentifiable, Watchable>, completion: ((Bool, NSError?) -> Void)) -> Request {
        return query(.RemoveFromHistory([object])) { response in
            guard let item = response.result.value as? JSONHash, added = item["deleted"] as? [String: Int], n = added[object.type.rawValue] where n > 0 else {
                return completion(false, response.result.error)
            }
            object.watched = false
            completion(true, nil)
        }
    }

    public func hideFromRecommendations(object: protocol<TraktIdentifiable, Watchable>, completion: ((Bool, NSError?) -> Void)? = nil) -> Request {
        return query(.HideRecommendation(object)) { response in
            completion?((response.response?.statusCode == 204) ?? false, response.result.error)
        }
    }

    public func addToWatchlist(object: protocol<TraktIdentifiable, Watchable>, completion: ((Bool, NSError?) -> Void)) -> Request {
        return query(.AddToWatchlist([object])) { response in
            guard let result = response.result.value as? JSONHash,
                added = result["added"] as? [String: Int],
                success = added[object.type.rawValue]
                where success == 1 else {
                    return completion(false, response.result.error)
            }
            object.watchlist = true
            completion(true, nil)
        }
    }

    public func removeFromWatchlist(object: protocol<TraktIdentifiable, Watchable>, completion: ((Bool, NSError?) -> Void)) -> Request {
        return query(.RemoveFromWatchlist([object])) { response in
            guard let result = response.result.value as? JSONHash,
                added = result["deleted"] as? [String: Int],
                success = added[object.type.rawValue]
                where success == 1 else {
                    return completion(false, response.result.error)
            }
            object.watchlist = false
            completion(true, nil)
        }
    }

    /// Load casting and crew for a given type/id (movie,show)
    public func people(type: TraktType, id: TraktIdentifier, completion: (([TraktCharacter]?, [TraktCrew]?, NSError?) -> Void)) -> Request {
        return query(.People(type, id)) { response in
            guard let result = response.result.value as? JSONHash else {
                return completion(nil, nil, response.result.error)
            }

            let casting = (result["cast"] as? [JSONHash])?.flatMap {
                TraktCharacter(data: $0)
            }
            // possible keys: production, art, crew, costume & make-up, directing, writing, sound, and camera
            let crew = (result["crew"] as? [String: [JSONHash]])?.values.flatMap({$0}).flatMap {
                TraktCrew(data: $0)
            }
            completion(casting, crew, response.result.error)
        }
    }

    /// Load credits for a given person, and media type
    public func credits(person: TraktPerson, type: TraktType, completion: (([TraktWatchable]?, NSError?) -> Void)) -> Request {
        return query(.Credits(type, person.id)) { response in
            guard let result = response.result.value as? JSONHash else {
                return completion(nil, response.result.error)
            }
            var list: Set<TraktWatchable> = []
            if let crew = result["crew"] as? [String: [JSONHash]] {
                crew.flatMap({
                    return $0.1.flatMap({
                        guard let item = $0[type.single] as? JSONHash else {
                            return nil
                        }
                        return type == .Movies ? TraktMovie(data: item) : TraktShow(data: item)
                    })
                }).forEach({
                    list.insert($0)
                })
            }
            if let cast = result["cast"] as? [JSONHash] {
                cast.flatMap({
                    guard let item = $0[type.single] as? JSONHash else {
                        return nil
                    }
                    return type == .Movies ? TraktMovie(data: item) : TraktShow(data: item)
                }).forEach({
                    list.insert($0)
                })
            }
            completion(Array(list), response.result.error)
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
                    fatalError("Not handled \(type)")
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
                    lastWatchedAt = Trakt.datetimeFormatter.dateFromString(lastAt) else {
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

    public func collection(type: TraktType, completion: (([TraktWatchable]?, NSError?) -> Void)) -> Request {
        return query(.Collection(type)) { response -> Void in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            let list: [TraktWatchable] = entries.flatMap {
                if type == .Shows {
                    return TraktShow(data: $0[type.single] as? JSONHash)
                } else if type == .Movies {
                    return TraktMovie(data: $0[type.single] as? JSONHash)
                } else {
                    return nil
                }
            }
            completion(list, nil)
        }
    }

    public func trending(type: TraktType, pagination: TraktPagination! = nil, completion: ([TraktWatchable]?, NSError?) -> Void) -> Request {
        return query(.Trending(type, pagination ?? TraktPagination(page: 1, limit: 100))) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            let list: [TraktWatchable] = entries.flatMap {
                if type == .Movies {
                    return TraktMovie(data: $0[type.single] as? JSONHash)
                } else if type == .Shows {
                    return TraktShow(data: $0[type.single] as? JSONHash)
                } else {
                    return nil
                }
            }
            completion(list, response.result.error)
        }
    }

    public func recommendations(type: TraktType, pagination: TraktPagination! = nil, completion: ([TraktWatchable]?, NSError?) -> Void) -> Request {
        return query(.Recommandations(type, pagination ?? TraktPagination(page: 1, limit: 100))) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
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
        }
    }

    public func rate(object: protocol<TraktIdentifiable, Watchable>, rate: Int, completion: (Bool, NSError?) -> Void) -> Request {
        return query(.Rate(object, rate)) { response in
            guard let item = response.result.value as? JSONHash, added = item["added"] as? [String: Int], n = added[object.type.rawValue] where n > 0 else {
                return completion(false, response.result.error)
            }
            completion(true, nil)
        }
    }

    public func movie(id: AnyObject, completion: (TraktMovie?, NSError?) -> Void) -> Request {
        return query(.Movie(id)) { response in
            guard let item = response.result.value as? JSONHash, o = TraktMovie(data: item) else {
                print("Cannot find movie \(id)")
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }

    public func show(id: AnyObject, completion: (TraktShow?, NSError?) -> Void) -> Request {
        return query(.Show(id)) { response in
            guard let item = response.result.value as? JSONHash, o = TraktShow(data: item) else {
                print("Cannot find show \(id)")
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }

    public func episodes(id: AnyObject, seasonNumber: Int, completion: ([TraktEpisode]?, NSError?) -> Void) -> Request {
        return query(.Season(id, seasonNumber)) { response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(items.flatMap{ TraktEpisode(data: $0) }, response.result.error)
        }
    }

    public func seasons(id: AnyObject, completion: ([TraktSeason]?, NSError?) -> Void) -> Request {
        return query(.Season(id, nil)) { response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(items.flatMap{ TraktSeason(data: $0) }, response.result.error)
        }
    }

    public func searchEpisode(id: AnyObject, season: Int, episode: Int, completion: (TraktEpisode?, NSError?) -> Void) -> Request {
        return query(.Episode(showId: id, season: season, episode: episode)) { response in
            guard let item = response.result.value as? JSONHash, o = TraktEpisode(data: item) else {
                print("Cannot find episode \(id)")
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }

    public func episode(episode: TraktEpisode, completion: (Bool, NSError?) -> Void) -> Request? {
        if episode.loaded != nil && episode.loaded == false {
            episode.loaded = nil
            return query(.Episode(showId: episode.season!.show!.id, season: episode.season!.number, episode: episode.number)) { response in
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

    public func progress(show: TraktShow, completion: ((Bool, NSError?) -> Void)) -> Request {
        return query(.Progress(show)) { response in
            guard let data = response.result.value as? JSONHash else {
                return completion(false, response.result.error)
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

            return completion(true, response.result.error)
        }
    }

    public func search(query: String, type: TraktType? = nil, year: Int? = nil, pagination: TraktPagination? = nil, completion: (([TraktObject]?, NSError?) -> Void)) -> Request {
        return self.query(.Search(query: query, type: type, year: year, pagination ?? TraktPagination(page: 1, limit: 100))) { response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            let list: [TraktObject]? = items.flatMap({
                TraktObject.autoload($0)
            })
            return completion(list, response.result.error)
        }
    }

    public func profile(name: String!, completion: (JSONHash?, NSError?) -> Void) -> Request {
        return query(.Profile(name)) { response in
            completion(response.result.value as? JSONHash, response.result.error)
        }
    }

    public func releases(movie: TraktMovie, countryCode: String? = nil, completion: ([TraktRelease]?, NSError?) -> Void) -> Request {
        return query(.Releases(movie, countryCode: countryCode)) { response in
            guard let data = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            movie.releases = data.flatMap {
                TraktRelease(data: $0)
            }
            completion(movie.releases, response.result.error)
        }
    }
}
