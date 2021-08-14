//
//  PasscodeLockType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public protocol PasscodeLockType {
    var delegate: PasscodeLockTypeDelegate? { get set }
    var state: PasscodeLockStateType { get }
    var isTouchIDAllowed: Bool { get }

    func addSign(_ sign: String)
    func removeSign()
    func changeState(_ state: PasscodeLockStateType)
    func authenticateWithTouchID()
}

public protocol PasscodeLockTypeDelegate: AnyObject {
    func touchIDDidSuccess(_ lock: PasscodeLockType)
    func touchIDDidFail(_ lock: PasscodeLockType)
    func passcodeLockDidChangeState(_ lock: PasscodeLockType)
    func passcodeLock(_ lock: PasscodeLockType, addedSignAt index: Int)
    func passcodeLock(_ lock: PasscodeLockType, removedSignAt index: Int)
    func passcodeDidReceive(_ passcode: String)
}

public protocol PasscodeLockViewControllerDelegate: AnyObject {
    func passcodeDidReceive(_ passcode: String, passcodeLockViewController: PasscodeLockViewController)
    func passcodeLockDidDismiss(success: Bool)
}
