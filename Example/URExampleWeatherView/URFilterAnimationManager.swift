//
//  URFilterAnimationManager.swift
//  URExampleWeatherView
//
//  Created by DongSoo Lee on 2017. 6. 7..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import Foundation

public typealias URFilterAnimationFireBlock = (Double) -> Any?
public class URFilterAnimationManager {
    var displayLink: CADisplayLink!
    var duration: TimeInterval = 1.0
    var transitionStartTime: CFTimeInterval = CACurrentMediaTime()
    var isRepeatForever: Bool = false

    @objc var timerFiredCallback: URFilterAnimationFireBlock

    lazy var buffers: [Any] = [Any]()
    var playCompletionCallback: (([Any]) -> Void)?
    var completionCallback: (() -> Void)?

    init(duration: TimeInterval, fireBlock: @escaping URFilterAnimationFireBlock) {
        self.duration = duration
        self.timerFiredCallback = fireBlock
    }

    init(duration: TimeInterval, startTime: CFTimeInterval, fireBlock: @escaping URFilterAnimationFireBlock) {
        self.duration = duration
        self.transitionStartTime = startTime
        self.timerFiredCallback = fireBlock

        self.displayLink = CADisplayLink(target: self, selector: #selector(timerFired(_:)))
        self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }

    func play(_ completion: (([Any]) -> Void)? = nil) {
        self.transitionStartTime = CACurrentMediaTime()

        self.displayLink = CADisplayLink(target: self, selector: #selector(timerFired(_:)))
        self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)

        guard let block = completion else { return }
        self.playCompletionCallback = block
    }

    func stop(_ completion: (() -> Void)? = nil) {
        self.isRepeatForever = false

        guard let block = completion else { return }
        self.completionCallback = block
    }

    @objc private func timerFired(_ displayLink : CADisplayLink) {
        let progress = min((CACurrentMediaTime() - self.transitionStartTime) / self.duration, 1.0)
        print("this is \(self.displayLink), displaylink is \(displayLink), progress : \(progress), mediatime is \(CACurrentMediaTime()), self.transitionStartTime is \(self.transitionStartTime), duration : \(self.duration)")
        if let returnValue = self.timerFiredCallback(progress) {
            self.buffers.append(returnValue)
        }

        if progress == 1.0 {
            if self.isRepeatForever {
                self.transitionStartTime = CACurrentMediaTime()
            } else {
                if let block = self.playCompletionCallback {
                    block(self.buffers)
                }

                displayLink.invalidate()
                self.buffers = [Any]()

                guard let block = self.completionCallback else { return }
                block()
            }
        }
    }
}
