//
//  InterstitialProvider.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 9/10/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension FullScreenAdInsterstitiable {
    var interstitialWrapper: GADInterstitialAd? {
        interstitial as? GADInterstitialAd
    }
}

/// Default implementation for AdMob provider on Interstitial ads
final public class InterstitialProvider: NSObject, FullScreenAdInsterstitiable {
    public var adUnitId: String
    
    public var interstitial: NSObject? {
        didSet {
            interstitialWrapper?.fullScreenContentDelegate = self
        }
    }

    weak public var adDelegate: InterstitialInteractable?

    /// Default init
    /// - Parameter identifier: interstitial's vendor identifier
    public init(identifier: String) {
        self.adUnitId = identifier
    }

    /// Loads the ad on a background queue. Upon load completion, `interstitial` reference is set and `InterstitialInteractable` notifies its listener
    public func loadAd() {
        let vendorId = adUnitId
        
        DispatchQueue.global(qos: .background).async {
            GADInterstitialAd.load(
                withAdUnitID: vendorId,
                request: GADRequest(),
                completionHandler: { [weak self] loadedAd, error in
                    if let error = error {
                        self?.adDelegate?.failedToPresent(
                            dueTo: InterstitialCustomError.failedInit(vendorId: vendorId,
                                                                      additionalContext: error.localizedDescription)
                        )
                    }

                    self?.interstitial = loadedAd
                    self?.adDelegate?.adLoaded()
                }
            )
        }
    }

    /// Shows the loaded add. Main thread is guaranteed 
    /// - Parameter rootViewController: anchor view controller from where the ad will be launched
    public func showAd(from rootViewController: UIViewController) {
        guaranteeMainThread {
            self.interstitialWrapper?.present(fromRootViewController: rootViewController)
        }
    }

    deinit {
        print("+++++ Deallocated interstitial ++++++")
    }
}

extension InterstitialProvider: GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        adDelegate?.failedToPresent(dueTo: error)
    }

    /// Tells the delegate that the ad dismissed full screen content.
    ///
    /// It also preloads the next ad.
    /// [Source](https://developers.google.com/admob/ios/interstitial#register_for_callbacks)
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adDelegate?.dismissed()
        loadAd()
    }
}
