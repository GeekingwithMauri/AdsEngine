//
//  ImpressionForwardingTests.swift
//  AdsEngine
//
//  Created by Mauricio Chirino on 7/8/26.
//

import GoogleMobileAds
import XCTest
@testable import AdsEngine

/// Stand-in for a vendor full screen ad: the impression callback only needs an
/// identity to hand back, and no real ad object can be built without inventory.
final class FullScreenAdStub: NSObject, FullScreenPresentingAd {
    weak var fullScreenContentDelegate: FullScreenContentDelegate?
}

final class ImpressionForwardingTests: XCTestCase {
    /// An impression is the vendor's only statement that the banner was really
    /// on screen. If the provider swallows it, a caller counting ad exposure
    /// silently counts nothing, which reads exactly like "no ads served".
    @MainActor
    func test_bannerProviderForwardsVendorImpressionToItsDelegate() {
        // Given
        let spy = AdInteractableSpy()
        let sut = BannerProvider(identifier: "dummyBannerId")
        sut.adDelegate = spy

        // When
        sut.bannerViewDidRecordImpression(BannerView(adSize: AdSizeBanner))

        // Verify
        XCTAssertEqual(
            spy.impressionCount,
            1,
            "The banner's vendor impression never reached the ad delegate"
        )
    }

    /// Same contract on the full screen side, where `adLoaded()` is an even
    /// worse proxy: an interstitial is loaded well ahead of being presented,
    /// and plenty of loaded ads are never shown at all.
    @MainActor
    func test_interstitialProviderForwardsVendorImpressionToItsDelegate() {
        // Given
        let spy = AdInteractableSpy()
        let sut = InterstitialProvider(identifier: "dummyInterstitialId")
        sut.adDelegate = spy

        // When
        sut.adDidRecordImpression(FullScreenAdStub())

        // Verify
        XCTAssertEqual(
            spy.impressionCount,
            1,
            "The interstitial's vendor impression never reached the ad delegate"
        )
    }

    /// The compatibility pin: `LegacyAdInteractable` never implements
    /// `adDidRecordImpression()`, so this call resolves to the protocol's
    /// default. That the file compiles is the real assertion — this test only
    /// pins that the default is reachable and harmless.
    func test_conformerWithoutTheImpressionCallbackStillSatisfiesTheProtocol() {
        // Given
        let sut: AdInteractable = LegacyAdInteractable()

        // When / Verify — a missing default would fail to compile, not to run
        sut.adDidRecordImpression()
    }
}
