//
//  AdInteractableSpies.swift
//  AdsEngine
//
//  Created by Mauricio Chirino on 7/8/26.
//

import AdsEngine
import Foundation

/// Records every callback the protocol can deliver.
final class AdInteractableSpy: InterstitialInteractable {
    private(set) var adLoadedCount = 0
    private(set) var failedToPresentCount = 0
    private(set) var dismissedCount = 0
    private(set) var impressionCount = 0

    func adLoaded() {
        adLoadedCount += 1
    }

    func failedToPresent(dueTo error: Error) {
        failedToPresentCount += 1
    }

    func dismissed() {
        dismissedCount += 1
    }

    func adDidRecordImpression() {
        impressionCount += 1
    }
}

/// Deliberately implements only the callbacks that predate `adDidRecordImpression()`.
///
/// This type exists to be compiled, not to be exercised: it is the standing
/// proof that the protocol's newest member carries a usable default, so a
/// conformer written before that member landed still builds untouched. Adding a
/// requirement without a default would break this file first, in this repo,
/// instead of in every consumer at once.
final class LegacyAdInteractable: AdInteractable {
    func adLoaded() {}

    func failedToPresent(dueTo error: Error) {}
}
