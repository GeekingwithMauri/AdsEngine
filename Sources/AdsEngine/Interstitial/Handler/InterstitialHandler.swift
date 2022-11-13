//
//  InterstitialHandler.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 4/9/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import UIKit

final class InterstitialHandler: InterstitialHandleable {
    private let adProvider: FullScreenAdInsterstitiable

    private var onCompletion: CompletionAction?

    init(adProvider: FullScreenAdInsterstitiable) {
        self.adProvider = adProvider
        self.adProvider.adDelegate = self
    }

    func loadAd() {
        adProvider.loadAd()
    }

    func showAd(from rootViewController: UIViewController, onCompletion: @escaping (CompletionAction)) {
        self.onCompletion = onCompletion
        adProvider.showAd(from: rootViewController)
    }
}

extension InterstitialHandler: InterstitialInteractable {
    func adLoaded() {
        print("==== Ad loaded =====")
    }

    func failedToPresent(dueTo error: Error) {
        onCompletion?(.failure(error))
    }

    func dismissed() {
        onCompletion?(.success(()))
    }
}
