//
//  InterstitialHandler.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 4/9/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import UIKit

/// Interstitial agnostic default implementation
/// Deferred-execution seam for load retries: production waits on the main
/// queue, tests run the work inline so they stay linear — no run-loop polling.
public typealias RetryScheduler = (TimeInterval, @escaping () -> Void) -> Void

final public class InterstitialHandler: InterstitialHandleable {
    private static let maxLoadRetries = 2

    private let adProvider: FullScreenAdInsterstitiable
    private let retryDelay: TimeInterval
    private let retryScheduler: RetryScheduler

    private var onCompletion: CompletionAction?
    private var loadRetriesLeft = InterstitialHandler.maxLoadRetries

    /// Default init
    /// - Parameter adProvider: ad facade to interact with
    /// - Parameter retryDelay: seconds between load retries after a failed ad request
    /// - Parameter retryScheduler: how the delayed retry gets executed
    public init(
        adProvider: FullScreenAdInsterstitiable,
        retryDelay: TimeInterval = 10,
        retryScheduler: @escaping RetryScheduler = { delay, work in
            DispatchQueue.main.asyncAfter(
                deadline: .now() + delay,
                execute: work
            )
        }
    ) {
        self.adProvider = adProvider
        self.retryDelay = retryDelay
        self.retryScheduler = retryScheduler
        self.adProvider.adDelegate = self
    }

    public func loadAd() {
        adProvider.loadAd()
    }

    public func showAd(
        from rootViewController: UIViewController,
        onCompletion: @escaping (CompletionAction)
    ) {
        guard adProvider.interstitial != nil else {
            // No loaded ad ⇒ the provider's showAd would silently do nothing and
            // this completion would never fire, freezing whatever flow awaits it.
            onCompletion(.failure(InterstitialError.adNotPresentable("No interstitial ad was loaded")))
            return
        }

        self.onCompletion = onCompletion
        adProvider.showAd(from: rootViewController)
    }
}

extension InterstitialHandler: InterstitialInteractable {
    public func adLoaded() {
        loadRetriesLeft = Self.maxLoadRetries
        print("==== Interstitial ad loaded =====")
    }

    public func failedToPresent(dueTo error: Error) {
        consumeCompletion(with: .failure(InterstitialError.adNotPresentable(error.localizedDescription)))
        retryShouldTheAdRequestHaveFailed(error)
    }

    public func dismissed() {
        consumeCompletion(with: .success(()))
    }

    /// One show, one completion: the provider preloads the next ad after a
    /// dismissal, and a failure on that background load must not re-fire the
    /// completion of a show that already finished.
    private func consumeCompletion(with result: Result<Void, Error>) {
        onCompletion?(result)
        onCompletion = nil
    }

    /// A failed ad request (no fill, flaky network — `failedInit`) retries a
    /// couple of times with a pause; without this, one failure at session start
    /// leaves the whole session ad-less. Present-time failures don't retry
    /// here — the provider already requests fresh inventory for those.
    private func retryShouldTheAdRequestHaveFailed(_ error: Error) {
        guard error is InterstitialCustomError, loadRetriesLeft > 0 else {
            return
        }

        loadRetriesLeft -= 1
        retryScheduler(retryDelay) { [weak self] in
            self?.loadAd()
        }
    }
}
