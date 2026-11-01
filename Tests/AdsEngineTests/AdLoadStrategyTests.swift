//
//  AdLoadStrategyTests.swift
//  AdsEngine
//

import GoogleMobileAds
import XCTest
@testable import AdsEngine

/// Records what a provider hands its loader. Loads nothing.
final class AdLoadStrategySpy {
    var placements: [String?] = []
    var bannerDelegates: [BannerViewDelegate] = []
    var interstitialCalls: [(adUnitID: String, delegate: FullScreenContentDelegate)] = []
    let interstitialCalled = XCTestExpectation(description: "interstitial loader called")

    var strategy: AdLoadStrategy {
        AdLoadStrategy(
            banner: { _, _, delegate in
                self.bannerDelegates.append(delegate)
            },
            interstitial: { adUnitID, _, delegate, _ in
                self.interstitialCalls.append((adUnitID, delegate))
                self.interstitialCalled.fulfill()
            }
        )
    }
}

/// The loader attaches the provider as the vendor's delegate: no other code
/// does. A provider that hands it anything else hears no vendor callback.
final class AdLoadStrategyTests: XCTestCase {
    @MainActor
    func test_bannerProviderHandsItselfToTheLoaderAsTheDelegate() {
        // Given
        let spy = AdLoadStrategySpy()
        let sut = BannerProvider(
            identifier: "dummyBannerId",
            loadStrategy: spy.strategy
        )
        sut.initBannerToBeIncluded(in: UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 320,
            height: 50
        )))

        // When
        sut.loadAd(for: UIViewController())

        // Verify
        XCTAssertEqual(
            spy.bannerDelegates.count,
            1
        )
        XCTAssertTrue(
            spy.bannerDelegates.first === sut,
            "The banner loader got a delegate other than the provider"
        )
    }

    func test_interstitialProviderHandsItsUnitAndItselfToTheLoader() {
        // Given
        let spy = AdLoadStrategySpy()
        let sut = InterstitialProvider(
            identifier: "dummyInterstitialId",
            loadStrategy: spy.strategy
        )

        // When
        sut.loadAd()
        wait(
            for: [spy.interstitialCalled],
            timeout: 5
        )

        // Verify
        XCTAssertEqual(
            spy.interstitialCalls.map(\.adUnitID),
            ["dummyInterstitialId"]
        )
        XCTAssertTrue(
            spy.interstitialCalls.first?.delegate === sut,
            "The interstitial loader got a delegate other than the provider"
        )
    }

    // MARK: - The configurator's strategy

    /// A provider built without a strategy loads with the configurator's,
    /// asked with the provider's placement: how an opt-in product reaches
    /// every provider without its callers naming it.
    @MainActor
    func test_bannerProviderWithoutAStrategyLoadsWithTheConfiguratorsForItsPlacement() {
        // Given
        let spy = AdLoadStrategySpy()
        let original = AdsConfigurator.loadStrategy
        addTeardownBlock { AdsConfigurator.loadStrategy = original }
        AdsConfigurator.loadStrategy = { placement in
            spy.placements.append(placement)
            return spy.strategy
        }
        let sut = BannerProvider(
            identifier: "dummyBannerId",
            placement: "home_banner"
        )
        sut.initBannerToBeIncluded(in: UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 320,
            height: 50
        )))

        // When
        sut.loadAd(for: UIViewController())

        // Verify
        XCTAssertEqual(
            spy.placements,
            ["home_banner"]
        )
        XCTAssertEqual(
            spy.bannerDelegates.count,
            1
        )
    }

    func test_interstitialProviderWithoutAStrategyLoadsWithTheConfiguratorsForItsPlacement() {
        // Given
        let spy = AdLoadStrategySpy()
        let original = AdsConfigurator.loadStrategy
        addTeardownBlock { AdsConfigurator.loadStrategy = original }
        AdsConfigurator.loadStrategy = { placement in
            spy.placements.append(placement)
            return spy.strategy
        }
        let sut = InterstitialProvider(
            identifier: "dummyInterstitialId",
            placement: "level_complete"
        )

        // When
        sut.loadAd()
        wait(
            for: [spy.interstitialCalled],
            timeout: 5
        )

        // Verify
        XCTAssertEqual(
            spy.placements,
            ["level_complete"]
        )
        XCTAssertEqual(
            spy.interstitialCalls.map(\.adUnitID),
            ["dummyInterstitialId"]
        )
    }
}
