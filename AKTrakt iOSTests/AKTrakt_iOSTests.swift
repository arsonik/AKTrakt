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

    func testRoute() {
        let expectation = expectationWithDescription("Searching for a show")


        trakt.show(39105) { (show, error) in
            XCTAssertEqual(show?.title, "Scandal")
            print(show?.overview)
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
            XCTAssertEqual(show.id, 39105)
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

        trakt.people(.Shows, id: 39105) { characters, crews, error in
            XCTAssertEqual(characters?.first?.character, "Olivia Pope")
            XCTAssertEqual(characters?.first?.person.name, "Kerry Washington")

            guard let producer = crews?.filter({ $0.job == "Executive Producer" }).first else {
                return XCTFail("Executive Producer not found")
            }
            XCTAssertEqual(producer.person.name, "Shonda Rhimes")

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testImages() {
        let expectation = expectationWithDescription("Getting movie")

        trakt.movie("tron-legacy-2010") { movie, error in
            XCTAssertTrue(movie?.images.count > 0)

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testSeasons() {
        let expectation = expectationWithDescription("Getting seasons")

        trakt.seasons(39105) { seasons, error in
            XCTAssertTrue(seasons?.count == 7)

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testEpisodes() {
        let expectation = expectationWithDescription("Getting episodes")

        trakt.episodes(39105, seasonNumber: 5) { episodes, error in
            XCTAssertTrue(episodes?.count == 21)
            XCTAssertEqual(episodes?.last?.title, "That's My Girl")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
