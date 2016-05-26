//
//  TraktAuthViewControllerDelegate.swift
//  Pods
//
//  Created by Florian Morello on 30/10/15.
//
//

import Foundation

public protocol TraktAuthViewControllerDelegate: class {
    func TraktAuthViewControllerDidAuthenticate(controller: UIViewController)
    func TraktAuthViewControllerDidCancel(controller: UIViewController)
}
