//
//  BannerRehostTests.swift
//  AdsEngine
//

import GoogleMobileAds
import XCTest
@testable import AdsEngine

/// A banner loaded before its screen exists is moved, not requested again.
@MainActor
final class BannerRehostTests: XCTestCase {
    func test_rehostMovesTheBannerIntoTheNewContainer() {
        // Given
        let sut = BannerProvider(
            identifier: "dummyBannerId",
            loadStrategy: AdLoadStrategySpy().strategy
        )
        sut.initBannerToBeIncluded(in: UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 320,
            height: 50
        )))
        let destination = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 320,
            height: 50
        ))

        // When
        sut.rehost(
            in: destination,
            rootViewController: UIViewController()
        )

        // Verify
        XCTAssertTrue(sut.bannerView.superview === destination)
    }

    func test_rehostPresentsFromTheNewController() {
        // Given
        let sut = BannerProvider(
            identifier: "dummyBannerId",
            loadStrategy: AdLoadStrategySpy().strategy
        )
        sut.initBannerToBeIncluded(in: UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 320,
            height: 50
        )))
        let controller = UIViewController()

        // When
        sut.rehost(
            in: UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: 320,
                height: 50
            )),
            rootViewController: controller
        )

        // Verify
        XCTAssertTrue(sut.bannerViewWrapper?.rootViewController === controller)
    }

    func test_rehostRequestsNothing() {
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
        sut.rehost(
            in: UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: 320,
                height: 50
            )),
            rootViewController: UIViewController()
        )

        // Verify
        XCTAssertEqual(
            spy.bannerDelegates.count,
            0
        )
    }
}
