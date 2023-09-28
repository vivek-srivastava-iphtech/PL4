//
//  InterstitialAdHelper.swift
//  PL2
//
//  Created by IPHTECH 24 on 08/08/22.
//  Copyright © 2022 IPHS Technologies. All rights reserved.
//

import Foundation
import GoogleMobileAds

protocol InterstitialAdHelperDelegate {
    func dismissIntersialAd()
    func showInterstitialMessage(message: String, status: String)
}

class InterstitialAdHelper : NSObject, GADFullScreenContentDelegate {
    var interstitialAd : GADInterstitialAd?
    
    var delegate: InterstitialAdHelperDelegate?
    
    func loadInterstitial() {
        print("[Ad request - interstitial]")
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:INTERSIAL_AD_Unit_Id,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("[Failed to load interstitial ad with error: \(error.localizedDescription)]")
                return
            }
            interstitialAd = ad
            interstitialAd?.fullScreenContentDelegate = self
        }
        )
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[Ad did fail to present full screen content - interstitial]")
        self.delegate?.showInterstitialMessage(message: "nil", status: "Failure")
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("[Ad will present full screen content - interstitial]")
        self.delegate?.showInterstitialMessage(message: "Show", status: "Success")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("[Ad did dismiss full screen content.]")
        self.delegate!.dismissIntersialAd()
    }
    
    func showIntersialAd(viewController: UIViewController) {
        if interstitialAd != nil {
            interstitialAd?.present(fromRootViewController: viewController)
//            self.delegate?.showInterstitialMessage(message: "Show", status: "Success")
        } else {
            print("[Ad wasn't ready]")
            self.delegate?.showInterstitialMessage(message: "nil", status: "Failure")
        }
    }
}
