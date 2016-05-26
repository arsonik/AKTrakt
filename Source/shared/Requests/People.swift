//
//  People.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation
import Alamofire

/// Get all people for an TraktMediaType object
public struct TraktRequestMediaPeople: TraktRequestGET, TraktRequestExtended {
    public var path: String
    public var params: JSONHash?

    public var extended: TraktRequestExtendedOptions?

    init(type: TraktMediaType, id: AnyObject, extended: TraktRequestExtendedOptions? = nil) {
        path = "/\(type.rawValue)/\(id)/people"
        self.extended = extended
    }
}

/// Get a single person
public struct TraktRequestPeople: TraktRequestGET, TraktRequestExtended {
    public var path: String
    public var params: JSONHash?

    public var extended: TraktRequestExtendedOptions?

    init(id: AnyObject, extended: TraktRequestExtendedOptions? = nil) {
        path = "/people/\(id)"
        self.extended = extended
    }
}

/// Get a person credits in a media type
public struct TraktRequestPeopleCredits: TraktRequestGET, TraktRequestExtended {
    public var path: String
    public var params: JSONHash?

    public var extended: TraktRequestExtendedOptions?

    init(type: TraktMediaType, id: AnyObject, extended: TraktRequestExtendedOptions? = nil) {
        path = "/people/\(id)/\(type.rawValue)"
        self.extended = extended
    }
}

extension Trakt {
    public func peoples(type: TraktMediaType, id: AnyObject, extended: TraktRequestExtendedOptions? = nil, completion: ([TraktCharacter]?, [TraktCrewPosition: [TraktCrew]]?, NSError?) -> Void) -> Request? {
        return request(TraktRequestMediaPeople(type: type, id: id, extended: extended)) { response in
            guard let result = response.result.value as? JSONHash else {
                return completion(nil, nil, response.result.error)
            }

            let casting = (result["cast"] as? [JSONHash])?.flatMap {
                TraktCharacter(data: $0)
            }
            var crew: [TraktCrewPosition: [TraktCrew]]? = nil
            if let crewData = (result["crew"] as? [String: [JSONHash]]) {
                crew = [:]
                crewData.forEach {
                    guard let position = TraktCrewPosition(rawValue: $0) else {
                        return
                    }
                    crew![position] = $1.flatMap {
                        TraktCrew(data: $0)
                    }
                }
            }
            completion(casting, crew, response.result.error)
        }
    }

    public typealias CreditsCompletionObject = (cast: [(character: String, media: TraktObject)]?, crew: [TraktCrewPosition: [(job: String, media: TraktObject)]]?)

    public func credits(id: AnyObject,
                        inMedia type: TraktMediaType,
                        extended: TraktRequestExtendedOptions? = nil,
                        completion: (CreditsCompletionObject?, NSError?) -> Void) -> Request? {
        return request(TraktRequestPeopleCredits(type: type, id: id, extended: extended)) { response in

            guard let result = response.result.value as? JSONHash else {
                return completion(nil, response.result.error)
            }

            var tuple: CreditsCompletionObject = (cast: [], crew: [:])
            // Crew
            (result["crew"] as? [String: [JSONHash]])?.forEach { key, values in
                guard let position = TraktCrewPosition(rawValue: key) else {
                    return
                }
                tuple.crew![position] = values.flatMap {
                    guard let job = $0["job"] as? String,
                        mediaData = $0[type.single] as? JSONHash,
                        media = (type == .Shows ? TraktShow(data: mediaData) : TraktMovie(data: mediaData)) as? TraktObject?
                        where media != nil else {
                        print("cannot find job or media")
                        return nil
                    }
                    return (job: job, media: media!)
                }
            }
            // Cast
            tuple.cast = (result["cast"] as? [JSONHash])?.flatMap {
                guard let character = $0["character"] as? String,
                    mediaData = $0[type.single] as? JSONHash,
                    media = (type == .Shows ? TraktShow(data: mediaData) : TraktMovie(data: mediaData)) as? TraktObject?
                    where media != nil else {
                    return nil
                }
                return (character: character, media: media!)
            }

            completion(tuple, response.result.error)
        }
    }
}
