//
//  PublicTests.swift
//  AKTrakt
//
//  Created by Florian Morello on 25/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import AKTrakt

class PublicTests: XCTestCase {

    let trakt = Trakt(clientId: "37558e63c821f673801c2c0788f4f877f5ed626bf5ba4493626173b3ac19b594",
                      clientSecret: "9a80ed5b84182af99be0a452696e68e525b2c629e6f2a9a7cd748e4147d85690",
                      applicationId: 3695)

    func testSearchMovie() {
        let expectation = expectationWithDescription("Searching for a movie")
        TraktRequestSearch(query: "avatar", type: TraktMovie.self).request(trakt) { result, error in
            guard let movie = result?.first as? TraktMovie else {
                return XCTFail("Response was not a TraktMovie: \(result), error \(error)")
            }

            XCTAssertEqual(movie.title, "Avatar")
            XCTAssertEqual(movie.year, 2009)

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testRoute() {
        let expectation = expectationWithDescription("Searching for a show")
        TraktRequestShow(id: 39105).request(trakt) { show, error in
            XCTAssertNil(show?.overview)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testRouteExtended() {
        let expectation = expectationWithDescription("Searching for a show extended")
        TraktRequestShow(id: 39105, extended: .Full).request(trakt) { (show, error) in
            XCTAssertNotNil(show?.overview)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testSearchShow() {
        let expectation = expectationWithDescription("Searching for a show")
        TraktRequestSearch(query: "scandal", type: TraktShow.self).request(trakt) { result, error in
            guard let show = result?.first as? TraktShow else {
                return XCTFail("Response was not a TraktShow")
            }
            XCTAssertEqual(show.title, "Scandal")
            XCTAssertEqual(show.id, 39105)
            XCTAssertEqual(show.year, 2012)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testTrending() {
        let expectation = expectationWithDescription("Getting trending")
        TraktRequestTrending(type: TraktMovie.self, extended: .Images, pagination: TraktPagination(page: 1, limit: 28)).request(trakt) { objects, error in
            XCTAssertTrue(objects?.first?.watchers > 0)
            XCTAssertNotNil(objects?.first?.media)
            XCTAssertTrue(objects?.first?.media.images.count > 0)
            XCTAssertEqual(objects?.count, 28)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testTokenFailure() {
        XCTAssertNil(TraktRequestRecommendations(type: TraktShow.self, extended: .Images, pagination: TraktPagination(page: 1, limit: 14)).request(trakt) { _, error in

        })
    }

    func testMovie() {
        let expectation = expectationWithDescription("Getting a movie by id")
        TraktRequestMovie(id: 1235).request(trakt) { movie, error in
            XCTAssertEqual(movie?.title, "Cervantes")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testPerson() {
        let expectation = expectationWithDescription("Getting a movie by id")
        TraktRequestPeople(id: "mel-gibson", extended: .Full).request(trakt) { person, error in
            XCTAssertEqual(person?.name, "Mel Gibson")
            XCTAssertEqual(person?.birthday?.description.containsString("1956-01-03"), true)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testCasting() {
        let expectation = expectationWithDescription("Getting casting")
        TraktRequestMediaPeople(type: TraktShow.self, id: 39105).request(trakt) { characters, crew, error in
            XCTAssertEqual(characters?.first?.character, "Olivia Pope")
            XCTAssertEqual(characters?.first?.person.name, "Kerry Washington")

            guard let exProducer = crew?[.Production]?.filter({ $0.job == "Executive Producer" }).first else {
                return XCTFail("Executive Producer not found")
            }
            XCTAssertEqual(exProducer.person.name, "Shonda Rhimes")

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testCredits() {
        let expectation = expectationWithDescription("Getting person's credits")

        TraktRequestPeopleCredits(type: TraktMovie.self, id: "mel-gibson").request(trakt) { tuple, error in
            guard let role = tuple?.cast?.filter({ $0.character == "Driver" }).first else {
                return XCTFail("Cannot find actor character")
            }
            XCTAssertEqual(role.media.title, "Get the Gringo")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testImages() {
        let expectation = expectationWithDescription("Getting movie")
        TraktRequestMovie(id: "tron-legacy-2010", extended: .Images).request(trakt) { movie, error in
            XCTAssertTrue(movie?.images.count > 0)

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testSeasons() {
        let expectation = expectationWithDescription("Getting seasons")
        TraktRequestSeason(showId: "game-of-thrones", seasonNumber: 1).request(trakt) { episodes, error in
            XCTAssertEqual(episodes?.count, 10)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testEpisodes() {
        let expectation = expectationWithDescription("Getting episodes")
        TraktRequestSeason(showId: 39105, seasonNumber: 5).request(trakt) { episodes, error in
            XCTAssertTrue(episodes?.count == 21)
            XCTAssertEqual(episodes?.last?.title, "That's My Girl")

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testReleases() {
        let expectation = expectationWithDescription("Getting releases")
        TraktRequestMovieReleases(id: "tron-legacy-2010", country: "fr").request(trakt) { releases, error in
            XCTAssertEqual(releases?.count, 1)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}
