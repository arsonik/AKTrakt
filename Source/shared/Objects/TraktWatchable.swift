//
//  TraktWatchable.swift
//  Arsonik
//
//  Created by Florian Morello on 04/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public protocol Castable: class {
    var crew: [TraktCrew]? { get set }
    var casting: [TraktCharacter]? { get set }
}

public protocol Watchable: class {
    var watched: Bool { get set }
    var watchlist: Bool { get set }
}

public class TraktWatchable: TraktObject, Watchable {
    public var title: String?
    public var overview: String?
    public var watched: Bool = false
    public var watchlist: Bool = false

    override public func digest(data: JSONHash?) {
        super.digest(data)

        title = data?["title"] as? String ?? title
        overview = data?["overview"] as? String ?? overview
        watched = data?["completed"] as? Bool ?? watched
    }
}
