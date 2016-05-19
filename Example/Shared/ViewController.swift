//
//  ViewController.swift
//  AKTrakt_TvOS_Example
//
//  Created by Florian Morello on 25/11/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import AKTrakt
import AlamofireImage

class ViewController: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView!
	var items: [TraktMovie] = []

	lazy var trakt: Trakt = {
		return Trakt(clientId: "37558e63c821f673801c2c0788f4f877f5ed626bf5ba4493626173b3ac19b594", clientSecret: "9a80ed5b84182af99be0a452696e68e525b2c629e6f2a9a7cd748e4147d85690", applicationId: 3695)
	} ()

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		if items.count == 0 {
			load()
		}
		if trakt.hasValidToken() {
			loadUser()
		}
	}

	@IBAction func displayAuth() {
		if let vc = TraktAuthenticationViewController.credientialViewController(trakt, delegate: self) {
			presentViewController(vc, animated: true, completion: nil)
		}
	}

	func load() {
		trakt.trending(.Movies) { [weak self] objects, error in
			if let movies = objects as? [TraktMovie] {
				self?.items = movies
				self?.collectionView.reloadData()
			}
		}
	}

	func loadUser() {
		trakt.profile(nil) { user, error in
			self.title = user?["username"] as? String
		}
	}

	@IBAction func clearToken(sender: AnyObject) {
		trakt.clearToken()
		title = "Trakt"
	}
}

extension ViewController: TraktAuthViewControllerDelegate {
	func TraktAuthViewControllerDidAuthenticate(controller: UIViewController) {
		loadUser()
		dismissViewControllerAnimated(true, completion: nil)
	}

	func TraktAuthViewControllerDidCancel(controller: UIViewController) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items.count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		return collectionView.dequeueReusableCellWithReuseIdentifier("movie", forIndexPath: indexPath)
	}

	func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		if let image = (cell.viewWithTag(1) as? UIImageView), url = items[indexPath.row].imageURL(.Poster, thatFits: image) {
			image.af_setImageWithURL(url)
		}
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		// Here you have the selected movie
		print(items[indexPath.row].title)
	}
}
