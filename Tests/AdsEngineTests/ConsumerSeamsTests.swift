//
//  ConsumerSeamsTests.swift
//  AdsEngine
//
//  Created by Mauricio Chirino on 08/09/26.
//

import GoogleMobileAds
import XCTest
@testable import AdsEngine

/// The three seams a consumer needs so it can put the SDK behind this facade
/// without regressing a decision it made on purpose: non-personalized requests,
/// a fixed banner size, and a single-shot interstitial.
final class ConsumerSeamsTests: XCTestCase {
    // MARK: - Request options

    /// The whole point of the seam. `npa=1` is invisible when wrong — a
    /// personalized request still serves — and expensive in policy.
    func test_nonPersonalizedOptionsCarryNpaOne() {
        XCTAssertEqual(
            AdRequestOptions.nonPersonalized.additionalParameters,
            ["npa": "1"],
            "The non-personalized request lost its npa=1 flag"
        )
    }

    /// The vendor default an existing consumer gets without asking: a plain
    /// personalized request, nothing stamped on it.
    func test_personalizedOptionsAreBare() {
        XCTAssertTrue(
            AdRequestOptions.personalized.additionalParameters.isEmpty,
            "A personalized request should stamp nothing on the vendor request"
        )
    }

    // MARK: - Banner size

    func test_standardSizeIsTheFixed320x50Banner() {
        let resolved = BannerAdSize.standard.resolved(containerWidth: 9_999)

        XCTAssertEqual(
            resolved.size.width,
            AdSizeBanner.size.width
        )
        XCTAssertEqual(
            resolved.size.height,
            AdSizeBanner.size.height
        )
    }

    /// An explicit width wins over the container's — the caller is stating what
    /// slot the ad lands in, not asking the view to guess.
    func test_anchoredAdaptiveHonoursAnExplicitWidth() {
        let explicit = BannerAdSize.anchoredAdaptive(width: 320).resolved(containerWidth: 9_999)

        XCTAssertEqual(
            explicit.size.width,
            320
        )
        XCTAssertNotEqual(
            explicit.size.width,
            BannerAdSize.anchoredAdaptive.resolved(containerWidth: 9_999).size.width,
            "A pinned width and the container width resolved to the same banner — the pin did nothing"
        )
    }

    /// The ceiling never exceeds what the deprecated anchored size served
    /// (measured on SDK 13) and is at most 1 pt short of it.
    func test_anchoredCeilingTracksTheDeprecatedAnchoredHeights() {
        let widths: [CGFloat] = [320, 375, 390, 393, 402, 414, 428, 430, 440]
        let measured: [CGFloat] = [50, 59, 61, 61, 63, 65, 67, 67, 68]

        XCTAssertEqual(
            widths.map { BannerAdSize.anchoredCeiling(width: $0) },
            [50, 58, 60, 61, 62, 64, 66, 67, 68]
        )
        XCTAssertEqual(
            zip(
                widths,
                measured
            ).filter { BannerAdSize.anchoredCeiling(width: $0) > $1 }.count,
            0,
            "The ceiling lets a banner grow taller than it was"
        )
    }

    /// The resolved size carries the ceiling, not SDK 13's doubled "large" height.
    func test_anchoredAdaptiveResolvesToTheCeiling() {
        let resolved = BannerAdSize.anchoredAdaptive(width: 390).resolved(containerWidth: 9_999)

        XCTAssertEqual(
            resolved.size.height,
            60
        )
    }

    // MARK: - Interstitial auto-reload opt-out

    /// `loadAd()`'s first synchronous act is to claim the audio session. With
    /// auto-reload off, a dismissal must not trigger it — the consumer preloads
    /// on its own gate, and a request here is one it never asked for.
    @MainActor
    func test_dismissalDoesNotReloadWhenAutoReloadIsOff() {
        // Given — the vendor default, i.e. the state a stray loadAd() would change
        MobileAds.shared.audioVideoManager.isAudioSessionApplicationManaged = false
        let spy = AdInteractableSpy()
        let sut = InterstitialProvider(
            identifier: "dummy",
            autoReload: false
        )
        sut.adDelegate = spy

        // When
        sut.adDidDismissFullScreenContent(FullScreenAdStub())

        // Verify
        XCTAssertEqual(
            spy.dismissedCount,
            1,
            "The dismissal still has to reach the delegate"
        )
        XCTAssertFalse(
            MobileAds.shared.audioVideoManager.isAudioSessionApplicationManaged,
            "A dismissal reloaded the interstitial despite autoReload: false"
        )
    }
}
