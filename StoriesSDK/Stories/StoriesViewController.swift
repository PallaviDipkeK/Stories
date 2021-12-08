//
//  StoriesViewController.swift
//  OpenBook
//
//  Created by Pallavi Anant Dipke on 15/06/21.
//  Copyright © 2021 Open Digi Technologies Pvt Ltd. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var outerCollection: UICollectionView!
    @IBOutlet private weak var cancelBtn: UIButton!
    @IBOutlet private weak var stackViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    private var currentIndex: Int = 0
    private var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var tapGest: UITapGestureRecognizer!
    private var longPressGest: UILongPressGestureRecognizer!
    private var panGest: UIPanGestureRecognizer!
    var updateStoryStatus: (() -> Void)?
    var storiesData: [String] = ["story1.gif","story2.gif","story3","story4"]
    var activityController: UIActivityViewController?
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        cancelBtn.addTarget(self, action: #selector(cancelBtnTouched), for: .touchUpInside)
        stackViewTopConstraint.constant = hasTopNotch ? 67 : 37
        setupModel()
        addGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let storyBar = getCurrentStory() {
            storyBar.startAnimation()
        }
    }
    
    // MARK: - Methods
    private func setupModel() {
        currentIndex = 0
        outerCollection.reloadData()
        outerCollection.scrollToItem(at: IndexPath(item: 0, section: 0),
                                     at: .centeredHorizontally, animated: false)
    }
    
    func currentStoryIndexChanged(index: Int) {
        currentIndex = index
    }
    
    func showNextUserStory() {
        let newUserIndex = currentIndex + 1
        if newUserIndex < storiesData.count {
            currentIndex = newUserIndex
        } else {
            cancelBtnTouched()
        }
    }
    
    func showPreviousUserStory() {
        let newIndex = currentIndex - 1
        if newIndex >= 0 {
            currentIndex = newIndex
        } else {
            cancelBtnTouched()
        }
    }
    
    private func getCurrentStory() -> StoryBar? {
        if let cell = outerCollection.cellForItem(at: IndexPath(item: 0, section: 0)) as? OuterCell {
            cell.story = storiesData
            return cell.storyBar
        }
        return nil
    }
    
    private func pauseStory() {
        if let storyBar = getCurrentStory() {
            storyBar.pause()
        }
    }
    
    private func resumeStory() {
        if let storyBar = getCurrentStory() {
            addGesture()
            storyBar.resume()
        }
    }
    
    // MARK: - Button Actions
    @IBAction func cancelBtnTouched() {
        dismiss(animated: true, completion: { [weak self] in
            self?.updateStoryStatus?()
        })
    }
}

// MARK: - Gestures
extension StoriesViewController {
    func addGesture() {
        // for previous and next navigation
        tapGest = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGest)
        
        longPressGest = UILongPressGestureRecognizer(target: self,
                                                     action: #selector(panGestureRecognizerHandler))
        longPressGest.minimumPressDuration = 0.2
        view.addGestureRecognizer(longPressGest)
        /*
         swipe down to dismiss
         NOTE: Self's presentation style should be "Over Current Context"
         */
        panGest = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler))
        view.addGestureRecognizer(panGest)
    }
    
    func removeGestures() {
        view.removeGestureRecognizer(tapGest)
        view.removeGestureRecognizer(longPressGest)
        view.removeGestureRecognizer(panGest)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let touchLocation: CGPoint = gesture.location(in: gesture.view)
        let maxLeftSide = ((view.bounds.maxX * 40) / 100) // Get 40% of Left side
        if let storyBar = getCurrentStory() {
            if touchLocation.x < maxLeftSide {
                storyBar.previous()
            } else {
                storyBar.next()
            }
        }
    }
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        guard let storyBar = getCurrentStory() else { return }
        let touchPoint = sender.location(in: view?.window)
        if sender.state == .began {
            storyBar.pause()
            initialTouchPoint = touchPoint
        } else if sender.state == .changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                view.frame = CGRect(x: 0, y: max(0, touchPoint.y - initialTouchPoint.y),
                                    width: view.frame.size.width,
                                    height: view.frame.size.height)
            }
        } else if sender.state == .ended || sender.state == .cancelled {
            if touchPoint.y - initialTouchPoint.y > 200 {
                dismiss(animated: true, completion: { [weak self] in
                    self?.updateStoryStatus?()
                })
            } else {
                storyBar.resume()
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    guard let self = self else { return }
                    self.view.frame = CGRect(x: 0, y: 0,
                                             width: self.view.frame.size.width,
                                             height: self.view.frame.size.height)
                })
            }
        }
    }
}

// MARK: - Collection View Data Source and Delegate
extension StoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storiesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OuterCell", for: indexPath) as! OuterCell
        cell.weakParent = self
        cell.hasTopNotch = hasTopNotch
        cell.setStory(story: storiesData)
        return cell
    }
} 

// MARK: - Scroll View Delegate
extension StoriesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pauseStory()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resumeStory()
    }
}

// MARK: - UIViewController Extension
extension UIViewController {
    
    // MARK: - Properties
    var hasTopNotch: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
        } else {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
    }
}
