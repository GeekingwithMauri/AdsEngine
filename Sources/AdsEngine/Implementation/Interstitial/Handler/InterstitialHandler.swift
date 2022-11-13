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

    public func showAd(from rootViewController: UIViewController, onCompletion: @escaping (CompletionAction)) {
        self.onCompletion = onCompletion
        adProvider.showAd(from: rootViewController)
    }
}

extension InterstitialHandler: InterstitialInteractable {
    public func adLoaded() {
        print("==== Ad loaded =====")
    }

    public func failedToPresent(dueTo error: Error) {
        onCompletion?(.failure(error))
    }

    public func dismissed() {
        onCompletion?(.success(()))
    }
}
