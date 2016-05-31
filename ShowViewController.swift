//
//  ShowViewController.swift
//  AKTrakt
//
//  Created by Florian Morello on 31/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import UIKit
import AKTrakt
import AlamofireImage

class ShowViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    var show: TraktShow!
    var casting: [TraktCharacter] = []

    lazy var trakt: Trakt = {
        return Trakt.autoload()
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = show.title

        if let image = view.viewWithTag(1) as? UIImageView, url = show.imageURL(.FanArt, thatFits: image) {
            image.af_setImageWithURL(url, placeholderImage: nil)
        }

        loadSeasons()
        loadCasting()
    }

    func loadSeasons() {
        TraktRequestSeasons(showId: show.id, extended: [.Episodes, .Images]).request(trakt) { [weak self] seasons, error in
            guard seasons != nil else {
                return
            }
            self?.show?.seasons = seasons!
            self?.tableView.reloadData()
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "SEASON \(show.seasons[section].number)"
    }

    func loadCasting() {
        TraktRequestMediaPeople(type: .Shows, id: show.id, extended: .Images).request(trakt) { [weak self] casting, _, error in
            guard casting != nil else {
                return
            }
            self?.casting = casting!
            self?.collectionView.reloadData()
        }
    }
}

extension ShowViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return casting.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let character = casting[indexPath.row]
        if let image = cell.viewWithTag(1) as? UIImageView, url = character.person.imageURL(.HeadShot, thatFits: image) {
            image.layer.cornerRadius = 25
            image.af_setImageWithURL(url, placeholderImage: nil)
        }
    }
}

extension ShowViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return show.seasons.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return show.seasons[section].episodes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("episode") ?? UITableViewCell()
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let episode = show.seasons[indexPath.section].episodes[indexPath.row]
        cell.textLabel?.text = "Episode \(episode.number)"
        cell.detailTextLabel?.text = episode.title
//        if let url = show.seasons[indexPath.section].episodes[indexPath.row].imageURL(.Thumb, thatFits: cell.imageView) {
//            cell.imageView?.af_setImageWithURL(url, placeholderImage: nil)
//        }
    }
}
