//
//  AlertSystem.swift
//
//
//  Created by Thai Nguyen on 7/7/20.
//

import Foundation
import RxSwift

typealias AlertAction = ((AlertActionAppearance)->(NextAlertHandle?))?

struct AlertActionAppearance {
    let title: String
    let style: UIAlertAction.Style
    
    static func `default`() -> AlertActionAppearance {
        return AlertActionAppearance(title: "OK", style: .default)
    }
}
enum AlertPriority: Int, Comparable {
    static func < (lhs: AlertPriority, rhs: AlertPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case low
    case medium
    case high
    case highest
}

enum AlertState{
    case pending
    case shown
    case cancel
}

enum NextAlertHandle {
    case showNextAlert
    case notShowNextAlert
    case clearAllAlert
}

class Alert {
    
    private var title: String?
    var message: String?
    var priority: AlertPriority
    private var style: UIAlertController.Style
    private var alertAction: AlertAction
    private var actionAppearances: [AlertActionAppearance]
    private var timeCreate = Date().timeIntervalSince1970
    private var state: AlertState = .pending {
        didSet {
            stateSubject.onNext(state)
        }
    }
    var alerContainer: UIAlertController?
    private let nextActionObserveObject = PublishSubject<NextAlertHandle>()
    var nextActionObservable: Observable<NextAlertHandle> {
        return nextActionObserveObject.asObservable()
    }
    
    let stateSubject = BehaviorSubject<AlertState>(value: .pending)
    
    init(title: String,
         message: String,
         style: UIAlertController.Style = .alert,
         priority: AlertPriority = .medium,
         actionAppearances: [AlertActionAppearance] = [AlertActionAppearance.default()],
         action: AlertAction) {
        
        self.title = title
        self.message = message
        self.style = style
        self.priority = priority
        self.actionAppearances = actionAppearances
        self.alertAction = action
    }
    
    func show(in viewController: UIViewController? = nil) {
        alerContainer = UIAlertController(title: title, message: message, preferredStyle: style)
        actionAppearances.forEach {[weak self] (actionAppearance) in
            let action = UIAlertAction(title: actionAppearance.title, style: actionAppearance.style) { (_) in
                var nextState: NextAlertHandle = .showNextAlert
                if let alertAction = self?.alertAction {
                    nextState = alertAction(actionAppearance) ?? .showNextAlert
                }
                self?.nextActionObserveObject.onNext(nextState)
                
            }
            alerContainer!.addAction(action)
        }
        DispatchQueue.main.async {
            viewController?.present(self.alerContainer!, animated: true, completion: {[weak self] in
                self?.state = .shown
            })            
        }
    }
}

extension Alert: Equatable, Comparable {
    static func < (lhs: Alert, rhs: Alert) -> Bool {
        return lhs.priority < rhs.priority
    }
    
    static func == (lhs: Alert, rhs: Alert) -> Bool {
        return (lhs.message == rhs.message && lhs.title == lhs.title)
    }
}

class AlertSystem {
    private init() {}
    static let shared: AlertSystem = AlertSystem()
    private let bag = DisposeBag()
    private var alertsAreShowing: [Alert] = []
    private var alertsPending: [Alert] = []
//    private let alertSystemQueue = DispatchQueue(label: "com..AlertSystem")
    private var currentShowingViewController: UIViewController? {
        willSet {
            if (newValue != currentShowingViewController) {
                alertsPending.removeAll()
            }
        }
    }
    private var lastShowingAlert: Alert? {
        return alertsAreShowing.last
    }
    
    func show(_ alert: Alert, in viewController: UIViewController?) {
        if (alert == lastShowingAlert) {return}
        currentShowingViewController = viewController
        
        if let lastAlert = lastShowingAlert, lastAlert.priority < alert.priority {
            // must show alert with higher prority
            lastAlert.stateSubject.subscribe(onNext: {[weak self] (state) in
                if state == .shown {
                    self?.hideAllShowingAlert()
                    self?.showAlert(alert)
                }
            }, onError: {[weak self] (error) in
                self?.showAlert(alert)
            }).disposed(by: bag)
            
        } else {
            // Append to queue
            enterAlertsQueue(alert)
        }
    }
    
    private func hideAllShowingAlert() {
        alertsAreShowing.forEach { (alert) in
            alert.alerContainer?.dismiss(animated: true, completion:nil)
        }
        alertsAreShowing.removeAll()
    }
    
    private func enterAlertsQueue(_ alert: Alert) {
        if (!alertsPending.contains(where: {$0 == alert})) {
            print("Add to queue \(alertsPending.count)")
            alertsPending.append(alert)
        }
        
        guard alertsAreShowing.count > 0 else {
            showAlert(alert)
            return
        }
    }
    
    private func showAlert(_ alert: Alert) {
        alertsAreShowing.append(alert)
        alert.stateSubject.subscribe(onNext: { (state) in
            if (state == .shown) {
                self.alertsPending.removeAlert(alert)
            }
            }).disposed(by: bag)
        alert.show(in: currentShowingViewController)
        alert.nextActionObservable.subscribe(onNext: {[weak self] (state) in
            self?.handleNextAlert(with: state)
        }).disposed(by: bag)

    }
    
    private func handleNextAlert(with nextState: NextAlertHandle) {
        alertsAreShowing.removeLastAlert()
        switch nextState {
        case .showNextAlert:
            let sortedAlerts = alertsPending.sorted(by: {$0>$1})
            if let higherAlert = sortedAlerts.first {
                showAlert(higherAlert)
            }
            
        case .clearAllAlert:
            alertsPending.removeAll()
            
        default:
            break
        }
    }
}

extension Array where Element == Alert {
    mutating func removeAlert(_ alert: Alert) {
        if let index = self.firstIndex(of: alert) {
            self.remove(at: index)
        }
    }
    
    mutating func removeLastAlert(){
        guard let last = self.last else {return}
        self.removeAlert(last)
    }
}
