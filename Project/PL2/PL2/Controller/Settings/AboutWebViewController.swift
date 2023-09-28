//
//  AboutWebViewController.swift
//  PL2
//
//  Created by Lekha Mishra on 15/12/17.
//  Copyright © 2017 IPHS Technologies. All rights reserved.
//

import UIKit
import SVProgressHUD

class AboutWebViewController: UIViewController, UIWebViewDelegate{

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIButton!
    
    var resorceString = ""
    var loadUrl = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if loadUrl == "Help" {
            if let url = URL(string: "https://www.pixelcolorapp.com/help/") {
                webView.loadRequest(URLRequest(url: url))
            }
            else {
                if let docUrl = Bundle.main.url(forResource: resorceString, withExtension: "docx") {
                    webView.loadRequest(URLRequest(url: docUrl))
                }
            }
        }
        else if loadUrl == "About" {
            if let url = URL(string: "https://www.pixelcolorapp.com/about/") {
                webView.loadRequest(URLRequest(url: url))
            }
            else {
                if let docUrl = Bundle.main.url(forResource: resorceString, withExtension: "docx") {
                    webView.loadRequest(URLRequest(url: docUrl))
                }
            }
        }
        
        checkGoBackAvaiable()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.show()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarningAbout Shoaib")
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        SVProgressHUD.dismiss()
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('cookie-notice').style.display = 'none'")
        
        if "\(request.url!)" == "https://www.google.com/" {
            self.showPopUp()
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('cookie-notice').style.display = 'none'")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5 , execute: {
            SVProgressHUD.dismiss()
        })
        
        checkGoBackAvaiable()
    }
    
    func checkGoBackAvaiable() {
        
        if webView.canGoBack {
            backButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
        else {
            backButton.tintColor = UIColor.gray
        }
    }
    
    func showPopUp() {
        
        let alert = UIAlertController(title: NSLocalizedString("Sorry to see you go!", comment: ""), message: NSLocalizedString("\nWe’ll stop collecting your data\nin this game when you select “QUIT”.\nIf you change your mind,\nyou can continue playing at any time.\nNote: When you revisit the app,\nwe will ask for your consent once again.", comment: ""), preferredStyle: .alert)
        
        let quitAction = UIAlertAction(title: NSLocalizedString("QUIT", comment: ""), style: .default, handler: { action in
            self.appDelegate.logEvent(name: "Sorry_Quit", category: "Sorry", action: "sorry_quit")
            UserDefaults.standard.set("1", forKey: isKillByForce)
            exit(0);
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            print("Cancel")
        })
        
        alert.addAction(quitAction)
        alert.addAction(cancelAction)
        appDelegate.logEvent(name: "Sorry_Go", category: "Sorry", action: "Sorry_win")
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        
        if webView.canGoBack {
            webView.goBack()
        }
        
    }
    
}
