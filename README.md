# AKTrakt

[![CI Status](http://img.shields.io/travis/arsonik/AKTrakt.svg?style=flat)](https://travis-ci.org/arsonik/AKTrakt)
[![Version](https://img.shields.io/cocoapods/v/AKTrakt.svg?style=flat)](http://cocoapods.org/pods/AKTrakt)
[![License](https://img.shields.io/cocoapods/l/AKTrakt.svg?style=flat)](http://cocoapods.org/pods/AKTrakt)
[![Platform](https://img.shields.io/cocoapods/p/AKTrakt.svg?style=flat)](http://cocoapods.org/pods/AKTrakt)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

AKTrakt is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AKTrakt"
```

## Screenshots

![alt tag](https://raw.githubusercontent.com/arsonik/AKTrakt/master/Example/Screenshots/TVlogin.png)
![alt tag](https://raw.githubusercontent.com/arsonik/AKTrakt/master/Example/Screenshots/TVmovies.png)
![alt tag](https://raw.githubusercontent.com/arsonik/AKTrakt/master/Example/Screenshots/iOSmovies.png)

## Code

```swift
let trakt = Trakt(clientId: "37558e63c821f673801c2c0788f4f877f5ed626bf5ba4493626173b3ac19b594", clientSecret: "9a80ed5b84182af99be0a452696e68e525b2c629e6f2a9a7cd748e4147d85690", applicationId: 3695)

override func viewDidAppear(animated: Bool) {
	super.viewDidAppear(animated)

	if let vc = TvOsTraktAuthViewController.credientialViewController(trakt, delegate: self) {
		presentViewController(vc, animated: true, completion: nil)
	} else {
		trakt.trendingMovies { [weak self] movies, error in
			// movies is an array of TraktMovie object
		}
	}
}
```

A (probably not up to date) list of what you can request:
```swift
public func watched(objects: [TraktWatchable]) -> Request {

public func unWatch(objects: [TraktWatchable]) -> Request {

public func hideFromRecommendations(movie: TraktMovie) -> Request {

public func addToWatchlist(objects: TraktWatchable...) -> Request {

public func people(object: TraktWatchable, completion: ((succeed: Bool, error: NSError?) -> Void)) -> Request {

public func credits(person: TraktPerson, type: TraktType, completion: ((result: [TraktWatchable]?, error: NSError?) -> Void)) -> Request {

public func watchList(type: TraktType, completion: ((result: [TraktWatchable]?, error: NSError?) -> Void)) -> Request {

public func watched(type: TraktType, completion: ((result: [TraktWatchable]?, error: NSError?) -> Void)) -> Request {

public func collection(type: TraktType, completion: ((result: [TraktWatchable]?, error: NSError?) -> Void)) -> Request {

public func trending(type: TraktType, pagination: TraktPagination! = nil, completion: ([TraktWatchable]?, NSError?) -> Void) -> Request {

public func recommendations(type: TraktType, pagination: TraktPagination! = nil, completion: ([TraktWatchable]?, NSError?) -> Void) -> Request {

public func rate(object: TraktWatchable, rate: Int, completion: (Bool, NSError?) -> Void) -> Request {

public func searchMovie(id: AnyObject, completion: (TraktMovie?, NSError?) -> Void) -> Request {

public func searchEpisode(id: AnyObject, season: Int, episode: Int, completion: (TraktEpisode?, NSError?) -> Void) -> Request {

public func episode(episode: TraktEpisode, completion: (loaded: Bool) -> Void) -> Request? {

public func progress(show: TraktShow, completion: ((loaded: Bool, error: NSError?) -> Void)) -> Request {

public func search(query: String, type: TraktType! = nil, year: Int! = nil, pagination: TraktPagination! = nil, completion: ((results: [TraktObject]?, error: NSError?) -> 
```

Feel free to fork, and add more features !

## Author

Florian Morello, arsonik@me.com

## License

AKTrakt is available under the MIT license. See the LICENSE file for more info.
