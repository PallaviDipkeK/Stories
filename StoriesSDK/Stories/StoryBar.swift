//
//  StoriesViewController.swift
//  OpenBook
//
//  Created by Pallavi Anant Dipke on 15/06/21.
//  Copyright © 2021 Open Digi Technologies Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

class Segment {
    let nonAnimatingBar = UIView()
    let animatingBar = UIView()
    init() {
    }
}

protocol SegmentedProgressBarProtocol: AnyObject {
    func segmentedProgressBarChangedIndex(_ index: Int)
    func segmentedProgressBarReachEnd()
    func segmentedProgressBarReachPrevious()
}

class StoryBar: UIView {
    
    // MARK: - Properties
    weak var delegate: SegmentedProgressBarProtocol?
    var animatingBarColor = UIColor.systemYellow {
        didSet {
            updateColors()
        }
    }
    var nonAnimatingBarColor = UIColor.yellow {
        didSet {
            updateColors()
        }
    }
    var padding: CGFloat = 2.0
    private var segments = [Segment]()
    private let duration: TimeInterval
    private var currentAnimationIndex = 0
    private var barAnimation: UIViewPropertyAnimator?
    
    // MARK: - View life cycle methods
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.nonAnimatingBar)
            addSubview(segment.animatingBar)
            segments.append(segment)
        }
        updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateColors() {
        for segment in segments {
            segment.animatingBar.backgroundColor = animatingBarColor
            segment.nonAnimatingBar.backgroundColor = nonAnimatingBarColor
        }
    }
    
    private func getYPosition() -> CGFloat {
        let _appDelegator = UIApplication.shared.delegate! as! AppDelegate
        if let bottom = _appDelegator.window?.safeAreaInsets.bottom {
            return bottom
        } else {
            return 0
        }
    }
    
    // MARK: - Deinitialisers
    deinit {
        stop()
    }
}

// MARK: - Playback
extension StoryBar {
    func resetSegmentFrames() {
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding),
                                  y: getYPosition(),
                                  width: width,
                                  height: frame.height)
            segment.nonAnimatingBar.frame = segFrame
            segment.animatingBar.frame = CGRect(origin: segFrame.origin,
                                                size: CGSize(width: 0, height: segFrame.size.height))
            let cr = frame.height / 2
            segment.nonAnimatingBar.layer.cornerRadius = cr
            segment.animatingBar.layer.cornerRadius = cr
        }
    }
    
    func resetSegmentsTill(index: Int) {
        var resetTillIndex = index
        stop()
        if resetTillIndex > segments.count - 1 {
            resetTillIndex = segments.count - 1
        }
        currentAnimationIndex = resetTillIndex
        resetSegmentFrames()
        for segmentIdx in 0..<resetTillIndex {
            segments[segmentIdx].animatingBar.frame.size.width = segments[segmentIdx].nonAnimatingBar.frame.size.width
        }
    }
    
    func removeOldAnimation(newWidth: CGFloat = 0) {
        stop()
        let oldAnimatingBar = segments[currentAnimationIndex].animatingBar
        oldAnimatingBar.frame.size.width = newWidth
    }
    
    func previous() {
        removeOldAnimation()
        let newIndex = currentAnimationIndex - 1
        if newIndex < 0 {
            delegate?.segmentedProgressBarReachPrevious()
        } else {
            currentAnimationIndex = newIndex
            removeOldAnimation()
            delegate?.segmentedProgressBarChangedIndex(newIndex)
            animate(animationIndex: newIndex)
        }
    }
    
    func next() {
        let newIndex = currentAnimationIndex + 1
        if newIndex < segments.count {
            let oldSegment = segments[currentAnimationIndex]
            removeOldAnimation(newWidth: oldSegment.nonAnimatingBar.frame.width)
            delegate?.segmentedProgressBarChangedIndex(newIndex)
            animate(animationIndex: newIndex)
        } else {
            delegate?.segmentedProgressBarReachEnd()
        }
    }
}

// MARK: - Animations
extension StoryBar {
    func showStoryBar() {
        if alpha == 0 {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = 1
            }
        }
    }
    
    func hideStoryBar() {
        if alpha == 1 {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = 0
            }
        }
    }
    
    func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    func pause() {
        guard let barAnimation = barAnimation else { return }
        if barAnimation.isRunning {
            hideStoryBar()
            barAnimation.pauseAnimation()
        }
    }
    
    func resume() {
        guard let barAnimation = barAnimation else { return }
        if !barAnimation.isRunning {
            showStoryBar()
            barAnimation.startAnimation()
        }
    }
    
    func stop() {
        if barAnimation != nil {
            barAnimation?.stopAnimation(true)
            if barAnimation?.state == .stopped {
                barAnimation?.finishAnimation(at: .current)
            }
        }
    }
    
    func animate(animationIndex: Int = 0) {
        let currentSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        if barAnimation != nil {
            barAnimation = nil
        }
        showStoryBar()
        barAnimation = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: { 
            currentSegment.animatingBar.frame.size.width = currentSegment.nonAnimatingBar.frame.width
        })
        barAnimation?.addCompletion { [weak self] (position) in
            if position == .end {
                DispatchQueue.main.async {
                    self?.callNextStory()
                }
            }
        }
        barAnimation?.isUserInteractionEnabled = false
        barAnimation?.startAnimation()
    }
    
    func callNextStory() {
        next()
    }
}
