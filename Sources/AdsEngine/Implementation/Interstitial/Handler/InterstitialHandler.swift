//
//  InterstitialHandler.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 4/9/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import UIKit

/// Interstitial agnostic default implementation
final public class InterstitialHandler: InterstitialHandleable {
    private let adProvider: FullScreenAdInsterstitiable

    private var onCompletion: CompletionAction?

    /// Default init
    /// - Parameter adProvider: ad facade to interact with
    public init(adProvider: FullScreenAdInsterstitiable) {
        self.adProvider = adProvider
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
        print("==== Interstitial ad loaded =====")
    }

    public func failedToPresent(dueTo error: Error) {
        consumeCompletion(with: .failure(InterstitialError.adNotPresentable(error.localizedDescription)))
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
}
