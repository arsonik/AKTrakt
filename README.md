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

## Screenshots

![alt tag](https://raw.githubusercontent.com/arsonik/AKTrakt/master/Example/Screenshots/TVlogin.png)
![alt tag](https://raw.githubusercontent.com/arsonik/AKTrakt/master/Example/Screenshots/TVmovies.png)

## Author

Florian Morello, arsonik@me.com

## License

AKTrakt is available under the MIT license. See the LICENSE file for more info.
