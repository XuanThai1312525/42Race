//
//  LayoutExtension.swift
//  MyChart
//
//  Created by Nguyễn Quốc Tùng on 12/22/19.
//  Copyright © 2019 Earable. All rights reserved.
//

import UIKit

private var kViewTopConstraint: UInt8 = 0
private var kViewLeftConstraint: UInt8 = 0
private var kViewRightConstraint: UInt8 = 0
private var kViewBottomConstraint: UInt8 = 0
private var kViewWidthConstraint: UInt8 = 0
private var kViewHeightConstraint: UInt8 = 0
private var kViewRatioConstraint: UInt8 = 0
private var kViewCenterXConstraint: UInt8 = 0
private var kViewCenterYConstraint: UInt8 = 0
private var kViewAdditionalConstraints: UInt8 = 0
extension UIView { // layout vars
    var privateAdditionalConstraints: [String: NSLayoutConstraint]? {
        get {
            return objc_getAssociatedObject(self, &kViewAdditionalConstraints) as? [String: NSLayoutConstraint]
        }
        set {
            objc_setAssociatedObject(self, &kViewAdditionalConstraints, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var additionalConstraints: [String: NSLayoutConstraint] {
        get {
            if privateAdditionalConstraints == nil {
                privateAdditionalConstraints = [:]
            }
            return privateAdditionalConstraints!
        }
        set {
            privateAdditionalConstraints = newValue
        }
    }
    
    @IBOutlet var centerXLayoutConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &kViewCenterXConstraint) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &kViewCenterXConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet var centerYLayoutConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &kViewCenterYConstraint) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &kViewCenterYConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet var topLayoutConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &kViewTopConstraint) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &kViewTopConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet var leftLayoutConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &kViewLeftConstraint) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &kViewLeftConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet var bottomLayoutConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &kViewBottomConstraint) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &kViewBottomConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet var rightLayoutConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &kViewRightConstraint) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &kViewRightConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet var widthLayoutConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &kViewWidthConstraint) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &kViewWidthConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet var heightLayoutConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &kViewHeightConstraint) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &kViewHeightConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet var ratioLayoutConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &kViewRatioConstraint) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &kViewRatioConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

enum ViewFullScreenType {
    case TopLeftBottomRight
    case CenterXYWidthHeight
}

extension UIView { // layout
    func setAdditionalConstraint(_ constraint: NSLayoutConstraint, forKey key: String) {
        NSLayoutConstraint.activate([constraint])
        additionalConstraints[key] = constraint
    }
    
    func fullscreen(_ relativeView: UIView? = nil, type: ViewFullScreenType = .TopLeftBottomRight) {
        var view = relativeView
        if view == nil {
            view = superview
        }
        guard let sup = view else {return}
        translatesAutoresizingMaskIntoConstraints = false
        
        switch type {
        case .CenterXYWidthHeight:
            setCenterX(0.0, relativeToView: sup)
            setCenterY(0.0, relativeToView: sup)
            setWidth(0.0, relativeToView: sup)
            setHeight(0.0, relativeToView: sup)
            
        default:
            setTop(0.0, relativeToView: sup)
            setLeft(0.0, relativeToView: sup)
            setBottom(0.0, relativeToView: sup)
            setRight(0.0, relativeToView: sup)
        }
    }
    
    func centralize() {
        guard let sup = superview else {return}
        translatesAutoresizingMaskIntoConstraints = false
        setCenterX(0.0, relativeToView: sup)
        setCenterY(0.0, relativeToView: sup)
    }
    
    @discardableResult
    func setCenterX(_ constant: CGFloat, relativeToView: UIView, relativeAttribute: NSLayoutConstraint.Attribute = .centerX) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        centerXLayoutConstraint?.deactivate()
        let centerXCons = NSLayoutConstraint.init(item: self, attribute: .centerX, relatedBy: .equal, toItem: relativeToView, attribute: relativeAttribute, multiplier: 1.0, constant: constant)
        NSLayoutConstraint.activate([centerXCons])
        centerXLayoutConstraint = centerXCons
        return self
    }
    
    @discardableResult
    func setCenterY(_ constant: CGFloat, relativeToView: UIView, relativeAttribute: NSLayoutConstraint.Attribute = .centerY) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        centerYLayoutConstraint?.deactivate()
        let centerYCons = NSLayoutConstraint.init(item: self, attribute: .centerY, relatedBy: .equal, toItem: relativeToView, attribute: relativeAttribute, multiplier: 1.0, constant: constant)
        NSLayoutConstraint.activate([centerYCons])
        centerYLayoutConstraint = centerYCons
        return self
    }
    
    @discardableResult
    func setTop(_ constant: CGFloat, relativeToView: UIView, relativeAttribute: NSLayoutConstraint.Attribute = .top, relatedBy: NSLayoutConstraint.Relation = .equal) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        topLayoutConstraint?.deactivate()
        let topCons = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: relativeToView, attribute: relativeAttribute, multiplier: 1.0, constant: constant)
        NSLayoutConstraint.activate([topCons])
        topLayoutConstraint = topCons
        return self
    }
    
    @discardableResult
    func setLeft(_ constant: CGFloat, relativeToView: UIView, relativeAttribute: NSLayoutConstraint.Attribute = .left, relatedBy: NSLayoutConstraint.Relation = .equal) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        leftLayoutConstraint?.deactivate()
        let leftCons = NSLayoutConstraint.init(item: self, attribute: .left, relatedBy: .equal, toItem: relativeToView, attribute: relativeAttribute, multiplier: 1.0, constant: constant)
        NSLayoutConstraint.activate([leftCons])
        leftLayoutConstraint = leftCons
        return self
    }
    
    @discardableResult
    func setBottom(_ constant: CGFloat, relativeToView: UIView, relativeAttribute: NSLayoutConstraint.Attribute = .bottom, relatedBy: NSLayoutConstraint.Relation = .equal) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        bottomLayoutConstraint?.deactivate()
        let bottomCons = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: relatedBy, toItem: relativeToView, attribute: relativeAttribute, multiplier: 1.0, constant: constant)
        NSLayoutConstraint.activate([bottomCons])
        bottomLayoutConstraint = bottomCons
        return self
    }
    
    @discardableResult
    func setRight(_ constant: CGFloat, relativeToView: UIView, relativeAttribute: NSLayoutConstraint.Attribute = .right, relatedBy: NSLayoutConstraint.Relation = .equal) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        rightLayoutConstraint?.deactivate()
        let rightCons = NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: relativeToView, attribute: relativeAttribute, multiplier: 1.0, constant: constant)
        NSLayoutConstraint.activate([rightCons])
        rightLayoutConstraint = rightCons
        return self
    }
    
    @discardableResult
    func setWidth(_ constant: CGFloat, relativeToView: UIView? = nil, relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1.0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        widthLayoutConstraint?.deactivate()
        let widthCons = NSLayoutConstraint.init(item: self, attribute: .width, relatedBy: .equal, toItem: relativeToView, attribute: relativeToView == nil ? .notAnAttribute : .width, multiplier: multiplier, constant: constant)
        NSLayoutConstraint.activate([widthCons])
        widthLayoutConstraint = widthCons
        return self
    }
    
    @discardableResult
    func setHeight(_ constant: CGFloat, relativeToView: UIView? = nil, relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1.0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        heightLayoutConstraint?.deactivate()
        let heightCons = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: relation, toItem: relativeToView, attribute: relativeToView == nil ? .notAnAttribute : .height, multiplier: multiplier, constant: constant)
        NSLayoutConstraint.activate([heightCons])
        heightLayoutConstraint = heightCons
        return self
    }
    
    @discardableResult
    func setRatio(_ r: CGFloat, c: CGFloat = 0.0) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        ratioLayoutConstraint?.deactivate()
        let ratioCons = NSLayoutConstraint.init(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: r, constant: c)
        NSLayoutConstraint.activate([ratioCons])
        ratioLayoutConstraint = ratioCons
        return self
    }
}

extension UIView {
    func flashShow(_ completion: (() -> Void)? = nil) {
        guard isHidden else {return}
        alpha = 0.0
        isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
        }) { (_) in
            completion?()
        }
    }
    
    func flashHide(_ completion: (() -> Void)? = nil) {
        guard !isHidden else {return}
        alpha = 1.0
        isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
        }) { (_) in
            self.isHidden = true
            completion?()
        }
    }
    
    static func instanceFrom<T: UIView>(_ type: T.Type) -> T {
        return UIView.instanceWith(String(describing: T.self)) as! T
    }
    
    static func instanceWith(_ name: String) -> UIView {
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as! UIView
    }
}

extension NSLayoutConstraint {
    func deactivate() {
        NSLayoutConstraint.deactivate([self])
    }
}

private var kPreviousHeight: UInt8 = 0
extension UIView {
    var previousHeight: CGFloat {
        get {
            return (objc_getAssociatedObject(self, &kPreviousHeight) as? CGFloat) ?? frame.size.height
        }
        set(item) {
            objc_setAssociatedObject(self, &kPreviousHeight, item, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var heightDeltaY: CGFloat {
        let currentHeight = layer.presentation()?.frame.size.height ?? frame.size.height
        return currentHeight - previousHeight
    }
}

private var kPreviousContentOffset: UInt8 = 0
private var kPreviousContentScrollState: UInt8 = 0
private var kPreviousAction: UInt8 = 0
private var kComplexAreaInset: UInt8 = 0
private var kScrollingUpDecelerating: UInt8 = 0
private var kStartTracking: UInt8 = 0
extension UIScrollView {
    var startTracking: Bool {
        get {
            return (objc_getAssociatedObject(self, &kStartTracking) as? Bool) ?? false
        }
        set(item) {
            objc_setAssociatedObject(self, &kStartTracking, item, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    enum ScrollState: String {
        case OutOfTop
        case Top
        case TopComplex
        case MiddleDynamic
        case BottomComplex
        case OutOfBottom
    }
    
    var previousScrollState: ScrollState {
        get {
            return (objc_getAssociatedObject(self, &kPreviousContentScrollState) as? ScrollState) ?? .Top
        }
        set(item) {
            objc_setAssociatedObject(self, &kPreviousContentScrollState, item, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var currentScrollState: ScrollState {
        if contentOffset.y < -contentInset.top {
            return .OutOfTop
        }
        else if contentOffset.y.isEqual(to: contentInset.top) {
            return .Top
        }
        else if contentOffset.y > contentInset.top && contentOffset.y <= complexAreaInset.top {
            return .TopComplex
        }
        else if contentOffset.y > complexAreaInset.top && contentOffset.y + bounds.size.height <= contentSize.height - fmax(complexAreaInset.top, complexAreaInset.bottom) * 2.0 {
            return .MiddleDynamic
        }
        else if contentOffset.y > maxContentOffset {
            return .OutOfBottom
        }
        return .BottomComplex
    }
    
    enum ScrollAction: String {
        case TrackingUp
        case TrackingDown
        case DeceleratingUp
        case DeceleratingDown
        case None
    }
    
    var previousAction: ScrollAction {
        get {
            return (objc_getAssociatedObject(self, &kPreviousAction) as? ScrollAction) ?? .None
        }
        set(item) {
            objc_setAssociatedObject(self, &kPreviousAction, item, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var currentAction: ScrollAction {
        if isTracking {
            if isUp {return .TrackingUp}
            if isDown {return .TrackingDown}
            return .None
        }
        else {
            if isDecelerating, isDown {return .DeceleratingDown}
            if isDecelerating, isUp {return .DeceleratingUp}
            return .None
        }
    }
    
    var isDown: Bool {
        return scrollingDeltaY > 0.0
    }
    
    var isUp: Bool {
        return scrollingDeltaY < 0.0
    }
    
    var complexAreaInset: UIEdgeInsets {
        get {
            return (objc_getAssociatedObject(self, &kComplexAreaInset) as? UIEdgeInsets) ?? .zero
        }
        set(item) {
            objc_setAssociatedObject(self, &kComplexAreaInset, item, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var previousContentOffset: CGPoint {
        get {
            return (objc_getAssociatedObject(self, &kPreviousContentOffset) as? CGPoint) ?? CGPoint(x: contentInset.left, y: contentInset.top)
        }
        set(item) {
            objc_setAssociatedObject(self, &kPreviousContentOffset, item, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var isScrollUpDecelerating: Bool {
        get {
            return (objc_getAssociatedObject(self, &kScrollingUpDecelerating) as? Bool) ?? false
        }
        set(item) {
            objc_setAssociatedObject(self, &kScrollingUpDecelerating, item, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var scrollingDeltaY: CGFloat {
        return scrollingDelta.y
    }
    
    var scrollingDelta: CGPoint {
        return CGPoint(x: contentOffset.x - previousContentOffset.x, y: contentOffset.y - previousContentOffset.y)
    }
    
    var maxContentOffset: CGFloat {
        if contentSize.height < bounds.size.height {
            let delta = contentInset.bottom - (bounds.size.height - contentSize.height)
            return 0.0 + (delta > 0.0 ? delta : 0.0)
        }
        return contentSize.height - bounds.size.height - contentInset.bottom
    }
}

extension UIScrollView {
    func visible(_ rect: CGRect, animated: Bool = true) {
        guard !bounds.contains(rect) else {return}
        if rect.origin.y < bounds.origin.y {
            setContentOffset(CGPoint(x: contentOffset.x, y: rect.origin.y), animated: animated)
        } else if rect.maxY > bounds.maxY {
            let newContentOffsetY = contentOffset.y + (rect.maxY - bounds.maxY)
            setContentOffset(CGPoint(x: contentOffset.x, y: newContentOffsetY), animated: animated)
        }
    }
}

var kNotificationHandlers: UInt32 = 0
extension NSObject {
    private var notificationHandlers: [NSNotification.Name: NotificationEventHandler]? {
        get {
            return objc_getAssociatedObject(self, &kNotificationHandlers) as? [NSNotification.Name: NotificationEventHandler]
        }
        set {
            objc_setAssociatedObject(self, &kNotificationHandlers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    typealias NotificationEventHandler = ((Notification) -> Void)
    
    func notificationEvents(_ names: [NSNotification.Name], handler: NotificationEventHandler?) {
        if notificationHandlers == nil {
            notificationHandlers = [:]
        }
        names.forEach { (name) in
            NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: name, object: nil)
            self.notificationHandlers?[name] = handler
        }
    }
    
    @objc private func notificationHandler(_ notification: Notification) {
        notificationHandlers?[notification.name]?(notification)
    }
}

extension CGPoint {
    func distanceTo(_ destinationPoint: CGPoint) -> CGFloat {
        return CGFloat(sqrtf(Float(pow(destinationPoint.x - x, 2) + pow(destinationPoint.y - y, 2))))
    }
    
    var vectorValue: CGFloat {
        return CGFloat(sqrtf(Float(pow(x, 2) + pow(y, 2))))
    }
}

extension UINavigationController {
    func removePreviousViewControllersInStackTo(_ vc: UIViewController, includeRoot: Bool = false) {
        guard viewControllers.count > 1 else {return}
        var controllers = viewControllers
        guard var index = controllers.firstIndex(of: vc) else {return}
        while (includeRoot && index > 0) || (!includeRoot && index > 1) {
            index -= 1
            controllers.remove(at: index)
        }
        setViewControllers(controllers, animated: false)
    }
    
    var currentTopViewController: UIViewController? {
        if let tabbar = topViewController as? UITabBarController {
            return (tabbar.selectedViewController as? UINavigationController)?.topViewController
        }
        return topViewController
    }
}

private var kTextFieldDoneAccessory: UInt8 = 0
extension UITextField {
    @IBInspectable final var doneAccessory: Bool {
        get {
            return objc_getAssociatedObject(self, &kTextFieldDoneAccessory) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &kTextFieldDoneAccessory, newValue, .OBJC_ASSOCIATION_ASSIGN)
            guard newValue else {return}
            addDoneButtonOnKeyboard()
        }
    }
    
    private func addDoneButtonOnKeyboard() {
        inputAccessoryView = getDoneButton("Done", target: self, selector: #selector(doneButtonAction))
    }
    
    @objc private func doneButtonAction() {
        resignFirstResponder()
    }
}

private var kTextViewTypingTimer: UInt8 = 0
private var kTextViewTypingDelaySeconds: UInt8 = 0
private var kTextViewEventDidEndEditing: UInt8 = 0
private var kTextViewEventDidBeginEditing: UInt8 = 0
private var kTextViewEventDidChange: UInt8 = 0
private var kTextViewEventDidChangeDelay: UInt8 = 0
extension UITextView {
    final var typingTimer: Timer? {
        get {
            return objc_getAssociatedObject(self, &kTextViewTypingTimer) as? Timer
        }
        set(item) {
            objc_setAssociatedObject(self, &kTextViewTypingTimer, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final var typingWaitingSeconds: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &kTextViewTypingDelaySeconds) as? TimeInterval ?? TimeInterval(0)
        }
        set(item) {
            objc_setAssociatedObject(self, &kTextViewTypingDelaySeconds, item, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    typealias EventHandler = ((String?) -> Void)
    final func event(_ controlEvent: UIControl.Event, handler: EventHandler? = nil, delaySeconds: TimeInterval = 0, delayHandler: EventHandler? = nil) {
        switch controlEvent {
        case .editingDidEnd:
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UITextView.textDidEndEditingNotification, object: nil)
            objc_setAssociatedObject(self, &kTextViewEventDidEndEditing, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        case .editingDidBegin:
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UITextView.textDidEndEditingNotification, object: nil)
            objc_setAssociatedObject(self, &kTextViewEventDidBeginEditing, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        case .editingChanged:
            typingWaitingSeconds = delaySeconds
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UITextView.textDidChangeNotification, object: nil)
            objc_setAssociatedObject(self, &kTextViewEventDidChange, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &kTextViewEventDidChangeDelay, delayHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        default:
            break
        }
    }
    
    @objc fileprivate func handleNotification(_ notification: Notification) {
        switch notification.name {
        case UITextView.textDidEndEditingNotification:
            typingTimer?.invalidate()
            typingTimer = nil
            (objc_getAssociatedObject(self, &kTextViewEventDidEndEditing) as? EventHandler)?(text)
            
        case UITextView.textDidBeginEditingNotification:
            (objc_getAssociatedObject(self, &kTextViewEventDidBeginEditing) as? EventHandler)?(text)
            
        case UITextView.textDidChangeNotification:
            (objc_getAssociatedObject(self, &kTextViewEventDidChange) as? EventHandler)?(text)
            guard typingWaitingSeconds > 0.0 else {break}
            typingTimer?.invalidate()
            typingTimer = Timer.scheduledTimer(timeInterval: typingWaitingSeconds, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: false)
            
        default:
            break
        }
    }
    
    @objc fileprivate func timerHandler() {
        typingTimer?.invalidate()
        typingTimer = nil
        (objc_getAssociatedObject(self, &kTextViewEventDidChangeDelay) as? EventHandler)?(text)
    }
}

private var kTextViewDoneAccessory: UInt8 = 0
extension UITextView {
    @IBInspectable final var doneAccessory: Bool {
        get {
            return objc_getAssociatedObject(self, &kTextViewDoneAccessory) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &kTextViewDoneAccessory, newValue, .OBJC_ASSOCIATION_ASSIGN)
            guard newValue else {return}
            addDoneButtonOnKeyboard()
        }
    }
    
    private func addDoneButtonOnKeyboard() {
        inputAccessoryView = getDoneButton("Done", target: self, selector: #selector(doneButtonAction))
    }
    
    @objc private func doneButtonAction() {
        resignFirstResponder()
    }
}

extension UITextInput {
    func getDoneButton(_ title: String = "Done", target: Any? = nil, selector: Selector? = nil) -> UIToolbar {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50.0))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: title, style: .done, target: target, action: selector)
        done.tintColor = UIColor.Unselected.gray
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        return doneToolbar
    }
}

extension UIView {
    func performShow(_ includeSubviews: Bool = true) {
        guard isHidden else {return}
        isHidden = false
        guard includeSubviews else {return}
        for v in subviews {
            v.alpha = 1.0
        }
    }
    
    func performHide(_ includeSubviews: Bool = true) {
        guard !isHidden else {return}
        isHidden = true
        guard includeSubviews else {return}
        for v in subviews {
            v.alpha = 0.0
        }
    }
}

extension UIRefreshControl {
    func endRefreshing(adjustAfterAnimated: Bool = false, completion: (() -> Void)? = nil) {
        endRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion?()
            guard let scrollView = self.superview as? UIScrollView, adjustAfterAnimated else {return}
            guard !scrollView.contentOffset.y.isZero, !scrollView.isDragging, !scrollView.isTracking else {return}
            scrollView.setContentOffset(.zero, animated: true)
        }
    }
}

extension UIColor {
    struct Selected {
        static let yellow = #colorLiteral(red: 1, green: 0.7215686275, blue: 0.2196078431, alpha: 1)
    }
    
    struct Unselected {
        static let gray = #colorLiteral(red: 0.3529411765, green: 0.3607843137, blue: 0.4039215686, alpha: 1)
    }
    
    struct Highlighted {
        static let blue = #colorLiteral(red: 0.2745098039, green: 0.431372549, blue: 0.7098039216, alpha: 1)
    }
    
    struct Background {
        static let darkGray = #colorLiteral(red: 0.08235294118, green: 0.0862745098, blue: 0.1058823529, alpha: 1)
        static let lightGray = #colorLiteral(red: 0.2078431373, green: 0.2117647059, blue: 0.2549019608, alpha: 1)
        static let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    static var random: UIColor {
        let number = arc4random() % 3
        switch number {
        case 0:
            return .blue
            
        case 1:
            return .yellow
            
        default:
            return .gray
        }
    }
}
