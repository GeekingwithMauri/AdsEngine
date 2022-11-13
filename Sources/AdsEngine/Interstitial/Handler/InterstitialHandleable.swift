//
//  InterstitialHandleable.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 10/10/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import Foundation
import UIKit

public typealias CompletionAction = (Result<Void, Error>) -> (Void)

public protocol InterstitialHandleable: AnyObject {
    func loadAd()
    func showAd(from rootViewController: UIViewController, onCompletion: @escaping (CompletionAction))
}
