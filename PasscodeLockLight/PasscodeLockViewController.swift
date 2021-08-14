//
//  PasscodeLockViewController.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

open class PasscodeLockViewController: UIViewController, PasscodeLockTypeDelegate {
    public enum LockState {
        case enter

        func getState() -> PasscodeLockStateType {
            switch self {
                case .enter: return EnterPasscodeState()
            }
        }
    }

    private static var nibName: String { return "PasscodeLockView" }

    open class var nibBundle: Bundle {
        return bundleForResource(name: nibName, ofType: "nib")
    }

    @IBOutlet open var placeholders: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var deleteSignButton: UIButton?
    @IBOutlet weak var touchIDButton: UIButton?
    @IBOutlet weak var placeholdersX: NSLayoutConstraint?
    @IBOutlet weak var imageView: UIImageView!
    
    open var animateOnDismiss: Bool = true
    open var notificationCenter: NotificationCenter?

    internal var passcodeLock: PasscodeLockType
    var state: PasscodeLockStateType {
        didSet {
            updatePasscodeView()
        }
    }
    internal var isPlaceholdersAnimationCompleted = true
    private var shouldTryToAuthenticateWithBiometrics = true
    
    public weak var delegate: PasscodeLockViewControllerDelegate?

    // MARK: - Initializers
    
    init(state: PasscodeLockStateType, animateOnDismiss: Bool = true) {
        self.state = state
        let this = type(of: self)
        passcodeLock = PasscodeLock(state: state)
        super.init(nibName: this.nibName, bundle: this.nibBundle)
    }

    public convenience init(state: LockState, animateOnDismiss: Bool = true) {
        self.init(state: state.getState(), animateOnDismiss: animateOnDismiss)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        clearEvents()
    }

    // MARK: - View
    open override func viewDidLoad() {
        super.viewDidLoad()

        updatePasscodeView()
        deleteSignButton?.isEnabled = false

        setupEvents()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if shouldTryToAuthenticateWithBiometrics {
            authenticateWithTouchID()
        }
    }
    
    internal func updatePasscodeView() {
        placeholders = placeholders.enumerated().map {
            $1.isHidden = $0 < state.passcodeLength ? false : true
            return $1
        }
        titleLabel?.text = state.title
        descriptionLabel?.text = state.description
        cancelButton?.setTitle(state.cancelButtonTitle, for: .normal)
        deleteSignButton?.setTitle(state.deleteButtonTitle, for: .normal)
        imageView.image = state.image
        
        passcodeLock = PasscodeLock(state: state)
        passcodeLock.delegate = self
        
        cancelButton?.isHidden = !passcodeLock.state.isCancellableAction
        touchIDButton?.isHidden = !passcodeLock.isTouchIDAllowed
    }

    // MARK: - Events

    private func setupEvents() {
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appWillEnterForegroundHandler(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appDidEnterBackgroundHandler(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    private func clearEvents() {
        notificationCenter?.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter?.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc open func appWillEnterForegroundHandler(_ notification: Notification) {
        authenticateWithTouchID()
    }

    @objc open func appDidEnterBackgroundHandler(_ notification: Notification) {
        shouldTryToAuthenticateWithBiometrics = false
    }

    // MARK: - Actions

    @IBAction func passcodeSignButtonTap(_ sender: PasscodeSignButton) {
        guard isPlaceholdersAnimationCompleted else { return }

        passcodeLock.addSign(sender.passcodeSign)
    }

    @IBAction func cancelButtonTap(_ sender: UIButton) {
        dismissPasscodeLock(success: false, passcodeLock)
    }

    @IBAction func deleteSignButtonTap(_ sender: UIButton) {
        passcodeLock.removeSign()
    }

    @IBAction func touchIDButtonTap(_ sender: UIButton) {
        passcodeLock.authenticateWithTouchID()
    }

    private func authenticateWithTouchID() {
        if state.shouldRequestTouchIDImmediately && passcodeLock.isTouchIDAllowed {
            passcodeLock.authenticateWithTouchID()
        }
    }

    internal func dismissPasscodeLock(success: Bool, _ lock: PasscodeLockType? = nil, completionHandler: (() -> Void)? = nil) {
        // if presented as modal
        if presentingViewController?.presentedViewController == self {
            dismiss(animated: animateOnDismiss) { [weak self] in
                self?.delegate?.passcodeLockDidDismiss(success: success)
            }
        } else {
            // if pushed in a navigation controller
            _ = navigationController?.popViewController(animated: animateOnDismiss)
            delegate?.passcodeLockDidDismiss(success: success)
        }
    }

    // MARK: - Animations

    internal func animateWrongPassword(completion: (()->Void)? = nil ) {
        deleteSignButton?.isEnabled = false
        isPlaceholdersAnimationCompleted = false

        animatePlaceholders(placeholders, toState: .error)

        placeholdersX?.constant = -40
        view.layoutIfNeeded()

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: { completed in
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(self.placeholders, toState: .inactive)
                completion?()
            }
        )
    }

    open func animatePlaceholders(_ placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        placeholders.forEach { $0.animateState(state) }
    }

    private func animatePlacehodlerAtIndex(_ index: Int, toState state: PasscodeSignPlaceholderView.State) {
        guard index < placeholders.count && index >= 0 else { return }

        placeholders[index].animateState(state)
    }

    // MARK: - PasscodeLockDelegate

    open func touchIDDidSuccess(_ lock: PasscodeLockType) {
        deleteSignButton?.isEnabled = true
        animatePlaceholders(placeholders, toState: .inactive)

        dismissPasscodeLock(success: true, lock) { [weak self] in
            self?.delegate?.passcodeLockDidDismiss(success: true)
        }
    }

    open func touchIDDidFail(_ lock: PasscodeLockType) {
        animateWrongPassword()
    }

    open func passcodeLockDidChangeState(_ lock: PasscodeLockType) {
        updatePasscodeView()
        animatePlaceholders(placeholders, toState: .inactive)
        deleteSignButton?.isEnabled = false
    }

    open func passcodeLock(_ lock: PasscodeLockType, addedSignAt index: Int) {
        animatePlacehodlerAtIndex(index, toState: .active)
        deleteSignButton?.isEnabled = true
    }

    open func passcodeLock(_ lock: PasscodeLockType, removedSignAt index: Int) {
        animatePlacehodlerAtIndex(index, toState: .inactive)
        if index == 0 {
            deleteSignButton?.isEnabled = false
        }
    }
    
    open func passcodeDidReceive(_ passcode: String) {
        delegate?.passcodeDidReceive(passcode, passcodeLockViewController: self)
    }
}
