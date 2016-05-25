//
//  AKTrakt_iOSTests.swift
//  AKTrakt iOSTests
//
//  Created by Florian Morello on 25/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import AKTrakt

class AKTrakt_iOSTests: XCTestCase {

    let trakt = Trakt(clientId: "37558e63c821f673801c2c0788f4f877f5ed626bf5ba4493626173b3ac19b594",
                      clientSecret: "9a80ed5b84182af99be0a452696e68e525b2c629e6f2a9a7cd748e4147d85690",
                      applicationId: 3695)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSearchMovie() {
        let expectation = expectationWithDescription("Searching for a movie")

        trakt.search("avatar", type: .Movies) { result, error in
            guard let movie = result?.first as? TraktMovie else {
                return XCTFail("Response was not a TraktMovie")
            }

            XCTAssertEqual(movie.title, "Avatar")
            XCTAssertEqual(movie.year, 2009)

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testSearchShow() {
        let expectation = expectationWithDescription("Searching for a show")

        trakt.search("scandal", type: .Shows) { result, error in
            guard let show = result?.first as? TraktShow else {
                return XCTFail("Response was not a TraktShow")
            }

            XCTAssertEqual(show.title, "Scandal")
            XCTAssertEqual(show.year, 2012)

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testCasting() {
        let expectation = expectationWithDescription("Getting casting")

        trakt.search("scandal", type: .Shows) { result, error in
            guard let show = result?.first as? TraktShow else {
                return XCTFail("Response was not a TraktShow")
            }

            self.trakt.casting(TraktType.Shows, id: show.ids.first!) { casting, crew, error in

                print(casting)
                print(crew)
                guard let character = casting?.first else {
                    return XCTFail("Response was not ok")
                }

                XCTAssertEqual(character.character, "Olivia Pope")
                XCTAssertEqual(character.person.name, "Kerry Washington")

                expectation.fulfill()
            }

        }
        waitForExpectationsWithTimeout(1) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
