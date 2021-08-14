//
//  PasscodeLockStateType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

public protocol PasscodeLockStateType {
    
    var title: String { get }
    var description: String { get }
    var passcodeLength: Int { get }
    var cancelButtonTitle: String { get }
    var deleteButtonTitle: String { get }
    var isCancellableAction: Bool { get }
    var isTouchIDAllowed: Bool { get }
    var shouldRequestTouchIDImmediately: Bool { get }
    var image: UIImage? {get}
    
//    mutating func accept(passcode: String, from lock: PasscodeLockType)
}
