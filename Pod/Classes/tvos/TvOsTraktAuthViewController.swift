//
//  TvOsTraktAuthViewController.swift
//  Pods
//
//  Created by Florian Morello on 30/10/15.
//
//

import UIKit

public class TvOsTraktAuthViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var pinField: UITextField!
    @IBOutlet weak var uriLabel: UILabel!

    public weak var delegate: TraktAuthViewControllerDelegate!
    public var trakt:Trakt!

    public override func viewDidLoad() {
        super.viewDidLoad()

        qrImageView.image = UIImage(named: "TraktQRCode.png", inBundle: bundle, compatibleWithTraitCollection: nil)
        uriLabel.text = "https://trakt.tv/pin/\(trakt.applicationId)"

    }

    lazy var bundle: NSBundle? = {
        let podBundle = NSBundle(forClass: self.classForCoder)
        if let bundleURL = podBundle.URLForResource("AKTraktTvOs", withExtension: "bundle") {
            return NSBundle(URL: bundleURL)
        }
        return nil
    } ()

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        let pinEntry = textField.text
        trakt.exchangePinForToken(pinEntry!) { [weak self] (token, error) -> Void in
            if token != nil {
                self?.trakt.saveToken(token: token)
                self?.delegate?.TraktAuthViewControllerDidAuthenticate(self!)
            }
            else {
                print("error while exchanging")
            }
        }
        return true
    }

    public static func test() -> TvOsTraktAuthViewController? {
        let podBundle = NSBundle(forClass: self.classForCoder())
        if let bundleURL = podBundle.URLForResource("AKTraktTvOs", withExtension: "bundle") {
            if let bundle = NSBundle(URL: bundleURL) {
                return TvOsTraktAuthViewController(nibName: "TvOsTraktAuthViewController", bundle: bundle)

            }else {
                assertionFailure("Could not load the bundle")
            }
        } else {
            assertionFailure("Could not create a path to the bundle")
        }
        return nil
    }
}