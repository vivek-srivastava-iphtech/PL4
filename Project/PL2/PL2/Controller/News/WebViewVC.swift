//
//  WebViewVC.swift
//  PL2
//
//  Created by iPHTech2 on 05/02/19.
//  Copyright © 2019 IPHS Technologies. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD
class WebViewVC: UIViewController,WKNavigationDelegate,WKUIDelegate {
    
    var webView : WKWebView!
    var webViewUrl:String = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: webViewUrl)
        let request = NSURLRequest(url: url! as URL)
        // webView = WKWebView(frame: self.view.frame)
      
        let webViewRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        webView = WKWebView(frame: webViewRect)
        webView.navigationDelegate = self
        webView.load(request as URLRequest)
        self.view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
         NotificationCenter.default.addObserver(self, selector: #selector(self.rotatedWebView), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
     @objc func rotatedWebView() {
        self.webView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.webView.layoutIfNeeded()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarningWebView Shoaib")
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        SVProgressHUD.dismiss()
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
        SVProgressHUD.show()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        SVProgressHUD.dismiss()
        //        let contentSize = webView.scrollView.contentSize;
        //        let viewSize = self.view.bounds.size;
        //
        //        let rw = viewSize.width / contentSize.width;
        //
        //        webView.scrollView.minimumZoomScale = rw;
        //        webView.scrollView.maximumZoomScale = rw;
        //        webView.scrollView.zoomScale = rw;
        webView.sizeToFit()
        
        self.webView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.webView.layoutIfNeeded()
      
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    
    //    func webViewDidFinishLoad() {
    //
    //        let savedUsername = "shoaib"
    //        let savedPassword = "shoaib123"
    //
    //        if savedUsername == nil || savedPassword == nil {return}
    //
    //
    //        let loadUsernameJS = "var inputFields = document.querySelectorAll(\"input[name='firstname']\"); \\ for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = \'\(savedUsername)\';}"
    //        let loadPasswordJS = "var inputFields = document.querySelectorAll(\"input[name='lastname']\"); \\ for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = \'\(savedPassword)\';}"
    //
    //        self.webView12.stringByEvaluatingJavaScript(from: loadUsernameJS)
    //        self.webView12.stringByEvaluatingJavaScript(from: loadPasswordJS)
    //
    //    }
    
    
}
