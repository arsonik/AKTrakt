//
//  LoggedTests.swift
//  AKTrakt
//
//  Created by Florian Morello on 09/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import AKTrakt

class LoggedTests: XCTestCase {

    let trakt = Trakt(clientId: "37558e63c821f673801c2c0788f4f877f5ed626bf5ba4493626173b3ac19b594",
                      clientSecret: "9a80ed5b84182af99be0a452696e68e525b2c629e6f2a9a7cd748e4147d85690",
                      applicationId: 3695)

    // arsonikTest
    let testToken = TraktToken(accessToken: "d69b61007069cdbc8999c09d4f254201baa60f5418b9ed39d622e02ee852fe2b",
                               expiresAt: Date(timeIntervalSince1970: 1473256416),
                               refreshToken: "8fc9bc42fd54a4181b983e5ed50e5e375e14664548057d8d416e889d6d0b55e2",
                               tokenType: "bearer",
                               scope: "public"
    )

    override func setUp() {
        super.setUp()

        trakt.token = testToken
    }

    func testProfile() {
        let expectation = self.expectation(withDescription: "Getting profile")
        TraktRequestProfile().request(trakt) { data, error in
            XCTAssertEqual(data?["username"] as? String, "arsonikTest")
            expectation.fulfill()
        }
        waitForExpectations(withTimeout: 5, handler: nil)
    }

    func testRecommendedMovies() {
        let expectation = self.expectation(withDescription: "Getting recommended movies")
        TraktRequestRecommendations(type: TraktMovie.self).request(trakt) { movies, error in
            XCTAssertEqual(movies?.count, 10)
            expectation.fulfill()
        }
        waitForExpectations(withTimeout: 5, handler: nil)
    }
}
