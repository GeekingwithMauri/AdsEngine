//
//  Dispatch.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 11/04/20.
//  Copyright © 2020 Mauricio Chirino. All rights reserved.
//

import UIKit

func guaranteeMainThread(using closure: @escaping () -> Void) {
    // If we are already on the main thread, execute the closure directly
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}
