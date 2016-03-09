//
//  TraktAuthViewController.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

public class TraktAuthViewController: UIViewController, WKNavigationDelegate {

    private var wkWebview: WKWebView!
	private weak var delegate: TraktAuthViewControllerDelegate!
	private let trakt: Trakt

    public init(trakt: Trakt, delegate: TraktAuthViewControllerDelegate) {
        self.trakt = trakt
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func embedInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")

        wkWebview = WKWebView(frame: view.bounds)
        wkWebview.navigationDelegate = self

        view.addSubview(wkWebview)

        initWebview()
    }


	public static func credientialViewController(trakt: Trakt, delegate: TraktAuthViewControllerDelegate) -> TraktAuthViewController? {
		if trakt.token == nil {
			return TraktAuthViewController(trakt: trakt, delegate: delegate)
		}
		return nil
	}

    public func cancel() {
        delegate?.TraktAuthViewControllerDidCancel(self)
    }

    private func initWebview() {
        wkWebview.loadRequest(NSURLRequest(URL: NSURL(string: "http://trakt.tv/pin/\(trakt.applicationId)")!))
    }

    private func pinFromNavigation(action: WKNavigationAction) -> String? {
        if let path = action.request.URL?.path where path.containsString("/oauth/authorize/") {
            let folders = path.componentsSeparatedByString("/")
            return folders[3]
        }
        return nil
    }

    public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let pin = pinFromNavigation(navigationAction) {
            decisionHandler(WKNavigationActionPolicy.Cancel)

            let request = TraktRoute.Token(client: trakt, pin: pin)
            Alamofire.request(request).responseJSON { (response) -> Void in
                if let token = TraktToken(data: response.result.value as? [String: AnyObject]) {
					self.trakt.saveToken(token: token)
                    self.delegate?.TraktAuthViewControllerDidAuthenticate(self)
                } else {

                    UIAlertView(title: "", message: "Failed to get a valid token", delegate: nil, cancelButtonTitle: "OK").show()
                    self.initWebview()
                }
            }
            return ()
        }
        decisionHandler(WKNavigationActionPolicy.Allow)
    }

    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error)
    }

    public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error)
    }
}
