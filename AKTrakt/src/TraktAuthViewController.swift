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

protocol TraktAuthViewControllerDelegate : class {
	func TraktAuthViewControllerDidAuthenticate(controller:TraktAuthViewController)
}

class TraktAuthViewController: UIViewController, WKNavigationDelegate {

    private var wkWebview: WKWebView!
	private weak var delegate: TraktAuthViewControllerDelegate!
	private let trakt: Trakt

    init(trakt: Trakt, delegate: TraktAuthViewControllerDelegate) {
        self.trakt = trakt
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        wkWebview = WKWebView(frame: view.bounds)
        wkWebview.navigationDelegate = self

        view.addSubview(wkWebview)

        initWebview()
    }
    
    private func initWebview(){
        wkWebview.loadRequest(NSURLRequest(URL: NSURL(string: "http://trakt.tv/pin/\(trakt.applicationId)")!))
    }

    private func pinFromNavigation(action: WKNavigationAction) -> String? {
        if let path = action.request.URL?.path where path.containsString("/oauth/authorize/") {
            let folders = path.componentsSeparatedByString("/")
            print(folders)
        }
        return nil
    }

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request.URL?.path)
        if let pin = pinFromNavigation(navigationAction) {
            decisionHandler(WKNavigationActionPolicy.Cancel)

            let request = TraktRoute.Token(client: trakt, pin: pin)
            Alamofire.request(request).responseJSON { (response) -> Void in
                if let token = TraktToken(data: response.result.value as? [String:AnyObject]) {
                    self.trakt.saveTokenToDefaults(token: token)
                    self.trakt.token = token
                    self.delegate?.TraktAuthViewControllerDidAuthenticate(self)
                }
                else{
                    UIAlertView(title: "", message: "Failed to get a valid token", delegate: nil, cancelButtonTitle: "OK").show()
                    self.initWebview()
                }
            }
            return ()
        }
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
}
