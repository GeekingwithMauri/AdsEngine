//
//  AdLoadStrategy.swift
//  AdsEngine
//

import GoogleMobileAds

/// How a provider hands its request to the vendor.
///
/// `.vendor` is the vendor's own load call. An opt-in product can supply a
/// loader that also reports each ad's events elsewhere. A loader attaches the
/// delegate it is given: the provider's callbacks arrive only through it.
public struct AdLoadStrategy {
    public typealias Banner = (
        _ view: BannerView,
        _ request: Request,
        _ delegate: BannerViewDelegate
    ) -> Void
    public typealias Interstitial = (
        _ adUnitID: String,
        _ request: Request,
        _ delegate: FullScreenContentDelegate,
        _ completion: @escaping (InterstitialAd?, Error?) -> Void
    ) -> Void

    let banner: Banner
    let interstitial: Interstitial

    public init(
        banner: @escaping Banner,
        interstitial: @escaping Interstitial
    ) {
        self.banner = banner
        self.interstitial = interstitial
    }

    /// The vendor's own calls, what the providers always made.
    public static let vendor = AdLoadStrategy(
        banner: { view, request, delegate in
            view.delegate = delegate
            view.load(request)
        },
        interstitial: { adUnitID, request, delegate, completion in
            InterstitialAd.load(
                with: adUnitID,
                request: request
            ) { ad, error in
                ad?.fullScreenContentDelegate = delegate
                completion(
                    ad,
                    error
                )
            }
        }
    )
}
