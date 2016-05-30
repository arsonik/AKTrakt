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
public class TraktRequestMediaPeople: TraktRequest, TraktRequest_Completion {
    public init(type: TraktMediaType, id: AnyObject, extended: TraktRequestExtendedOptions = .Min) {
        super.init(path: "/\(type.rawValue)/\(id)/people", params: extended.value())
    }

    public func request(trakt: Trakt, completion: ([TraktCharacter]?, [TraktCrewPosition: [TraktCrew]]?, NSError?) -> Void)-> Request? {
        return trakt.request(self) { response in
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
}

/// Get a single person
public class TraktRequestPeople: TraktRequest, TraktRequest_Completion {
    public init(id: AnyObject, extended: TraktRequestExtendedOptions = .Min) {
        super.init(path: "/people/\(id)", params: extended.value())
    }

    public func request(trakt: Trakt, completion: (TraktPerson?, NSError?) -> Void)-> Request? {
        return trakt.request(self) { response in
            completion(TraktPerson(data: response.result.value as? JSONHash), response.result.error)
        }
    }
}

/// Get a person credits in a media type

public typealias CreditsCompletionObject = (cast: [(character: String, media: TraktObject)]?, crew: [TraktCrewPosition: [(job: String, media: TraktObject)]]?)
public class TraktRequestPeopleCredits: TraktRequest, TraktRequest_Completion {
    let type: TraktMediaType

    public init(type: TraktMediaType, id: AnyObject, extended: TraktRequestExtendedOptions = .Min) {
        self.type = type
        super.init(path: "/people/\(id)/\(type.rawValue)", params: extended.value())
    }

    public func request(trakt: Trakt, completion: (CreditsCompletionObject?, NSError?) -> Void)-> Request? {
        return trakt.request(self) { response in
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
                        mediaData = $0[self.type.single] as? JSONHash,
                        media = (self.type == .Shows ? TraktShow(data: mediaData) : TraktMovie(data: mediaData)) as? TraktObject?
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
                    mediaData = $0[self.type.single] as? JSONHash,
                    media = (self.type == .Shows ? TraktShow(data: mediaData) : TraktMovie(data: mediaData)) as? TraktObject?
                    where media != nil else {
                        return nil
                }
                return (character: character, media: media!)
            }

            completion(tuple, response.result.error)
        }
    }
}
