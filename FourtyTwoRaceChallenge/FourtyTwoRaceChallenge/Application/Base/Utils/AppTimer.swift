//
//  AppTimer.swift
//  Earable
//
//  Created by Nguyen Quoc Tung on 12/19/19.
//  Copyright © 2019 Earable. All rights reserved.
//

import Foundation

final class TimerModel {
    private var timer: DispatchSourceTimer?
    var isRunning = false
    var skipCount = 2
    var name = ""
    
    private let internalQueue = DispatchQueue(label: "timer.internal")
    private let timerQueue = DispatchQueue(label: "timer.timer")
        
    func start(_ delays: Double = 0,
               repeatsTimeInterval: DispatchTimeInterval,
               repeats: Bool = true,
               queue: DispatchQueue? = nil,
               skip: Int = 0,
               fireImmediately: Bool = false,
               event: (() -> Void)?)
    {
        if isRunning {
            stop()
        }
        var q = queue
        if q == nil {
            q = timerQueue
        }
        internalQueue.sync { [weak self] in
            guard let _self = self else {return}
            _self.isRunning = true
            _self.skipCount += skip
            
            if fireImmediately {
                _self.skipCount -= 1
            }
            
            _self.timer = DispatchSource.makeTimerSource(flags: .strict, queue: q)
            _self.timer?.schedule(deadline: .now() + delays, repeating: repeatsTimeInterval, leeway: .milliseconds(10))
            _self.timer?.setEventHandler(handler: { [weak self] in
                guard let _self = self else {return}
                _self.skipCount -= 1
                _self.skipCount = max(_self.skipCount, 0)
                
                guard _self.skipCount == 0 else {return}
                
                event?()
                guard !repeats else {return}
                _self.stop()
            })
            _self.timer?.resume()
        }
    }
    
    func stop() {
        internalQueue.sync { [weak self] in
            guard let _self = self, _self.isRunning else {return}
            _self.timer?.setEventHandler(handler: nil)
            _self.timer?.cancel()
            _self.skipCount = 2
            _self.timer = nil
            _self.isRunning = false
        }
    }
}
