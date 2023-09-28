//
//  RewardedAdHelper.swift
//  PL2
//
//  Created by IPHTECH 24 on 08/08/22.
//  Copyright © 2022 IPHS Technologies. All rights reserved.
//

import Foundation
import GoogleMobileAds

protocol RewardedAdHelperDelegate {
    func dismissRewardedAd()
    func showReward(rewardAmount: String, status: String)
}

class RewardedAdHelper : NSObject, GADFullScreenContentDelegate {
    var rewardedAd : GADRewardedAd?
    
    var delegate: RewardedAdHelperDelegate?
    var rewardId: String?
    
    func loadRewardedAd(adId: String) {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: adId, request: request) { [self] ad, error in
            if let error = error {
                print("[Failed to load reward ad with error: \(error.localizedDescription)]")
                UserDefaults.standard.set(false, forKey: REWARD_LOAD)
                return
            }
            UserDefaults.standard.set(true, forKey: REWARD_LOAD)
            rewardedAd = ad
            rewardedAd?.fullScreenContentDelegate = self
            print("[Rewarded ad loaded.]")
        }
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[Ad did fail to present full screen content - reward]")
        self.delegate?.showReward(rewardAmount: "0", status: "Failure")
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("[Ad will present full screen content - reward]")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("[Ad did dismiss full screen content.]")
        self.delegate!.dismissRewardedAd()
        
        self.loadRewardedAd(adId: rewardId!)
    }
    
    func showRewardedAd(viewController: UIViewController) {
        
        if rewardedAd != nil {
                self.rewardedAd!.present(fromRootViewController: viewController, userDidEarnRewardHandler: {
                let reward = self.rewardedAd!.adReward
                print("[Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)]")
                self.delegate?.showReward(rewardAmount: "\(reward.amount)", status: "Success")
            })
        } else {
            print("[RewardedAd wasn't ready]")
            self.delegate?.showReward(rewardAmount: "0", status: "Failure")
        }
    }
}

