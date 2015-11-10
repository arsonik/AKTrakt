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

    internal weak var delegate: TraktAuthViewControllerDelegate!
    internal var trakt:Trakt!

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
				let ac = UIAlertController(title: "Trakt Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
				ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
					self?.navigationController?.dismissViewControllerAnimated(true, completion: nil)
				}))
				self?.presentViewController(ac, animated: true, completion: nil)
            }
        }
        return true
    }


	public static func credientialViewController(trakt: Trakt, delegate: TraktAuthViewControllerDelegate) -> TvOsTraktAuthViewController? {
		if trakt.token == nil {
			let podBundle = NSBundle(forClass: self.classForCoder())
			if let bundleURL = podBundle.URLForResource("AKTraktTvOs", withExtension: "bundle") {
				if let bundle = NSBundle(URL: bundleURL) {
					let vc = TvOsTraktAuthViewController(nibName: "TvOsTraktAuthViewController", bundle: bundle)
					vc.delegate = delegate
					vc.trakt = trakt
					return vc

				}
			}
		}
		return nil
	}
}