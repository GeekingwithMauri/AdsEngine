//
//  AudioSessionOwnershipTests.swift
//  AdsEngine
//
//  Created by Mauricio Chirino on 8/9/26.
//

import GoogleMobileAds
import XCTest
@testable import AdsEngine

/// The vendor's default is to rewrite the host app's `AVAudioSession` category to
/// `.ambient` / `.soloAmbient` around its video creatives — categories the Ring/Silent
/// switch silences. An app playing through a silenced phone on purpose loses its own
/// audio the moment an ad is requested, and never gets it back.
///
/// None of this is visible in a simulator, which has no Ring/Silent switch, so these
/// are the only automated guard the behaviour has.
final class AudioSessionOwnershipTests: XCTestCase {
    @MainActor
    override func setUp() {
        super.setUp()
        // The shipped vendor default — the state that causes the bug, so an assertion
        // below can genuinely fail rather than reading a flag someone already set.
        MobileAds.shared.audioVideoManager.isAudioSessionApplicationManaged = false
    }

    @MainActor
    func test_theVendorIsToldToLeaveTheAppsAudioSessionAlone() {
        // Given / When
        AdsConfigurator.leaveAudioSessionToTheApp()

        // Verify
        XCTAssertTrue(
            MobileAds.shared.audioVideoManager.isAudioSessionApplicationManaged,
            "The SDK is still managing AVAudioSession — a host app's sound dies on a silenced phone"
        )
    }

    /// The call site is the half that rots: the helper can stay perfect while a
    /// provider stops calling it. `loadAd` on a banner that was never placed in a
    /// container leaves every vendor line optional-chaining off `nil`, so this
    /// exercises the ownership claim without issuing a real ad request.
    ///
    /// `InterstitialProvider.loadAd()` makes the same call on its first line and is
    /// not covered here — its body reaches the network unconditionally, which is not
    /// something a unit test should do.
    @MainActor
    func test_loadingABannerClaimsTheAudioSessionForTheApp() {
        // Given
        let sut = BannerProvider(identifier: "dummyBannerId")

        // When
        sut.loadAd(for: UIViewController())

        // Verify
        XCTAssertTrue(
            MobileAds.shared.audioVideoManager.isAudioSessionApplicationManaged,
            "BannerProvider.loadAd no longer claims the audio session before requesting an ad"
        )
    }
}
