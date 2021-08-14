//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

public let PasscodeLockIncorrectPasscodeNotification = Notification.Name("passcode.lock.incorrect.passcode.notification")

struct EnterPasscodeState: PasscodeLockStateType {
    let title: String
    let description: String
    let isCancellableAction: Bool
    var isTouchIDAllowed = true
    var passcodeLength: Int
    var cancelButtonTitle: String
    var deleteButtonTitle: String
    var image: UIImage?
    var shouldRequestTouchIDImmediately: Bool = false
//    private var isNotificationSent = false

    init(allowCancellation: Bool = true) {
        isCancellableAction = allowCancellation
        title = localizedStringFor(key: "PasscodeLockEnterTitle", comment: "Enter passcode title")
        description = localizedStringFor(key: "PasscodeLockEnterDescription", comment: "Enter passcode description")
        passcodeLength = 8
        deleteButtonTitle = "Delete"
        cancelButtonTitle = "Cancel"
    }


    private mutating func postNotification() {
//        guard !isNotificationSent else { return }
//        NotificationCenter.default.post(name: PasscodeLockIncorrectPasscodeNotification, object: nil)
//        isNotificationSent = true
    }
}
