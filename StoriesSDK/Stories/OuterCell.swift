//
// StoriesViewController.swift
// OpenBook
//
// Created by Pallavi Anant Dipke on 15/06/21.
// Copyright © 2021 Open Digi Technologies Pvt Ltd. All rights reserved.
//

import UIKit

class OuterCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var innerCollection: UICollectionView!
    
    // MARK: - Properties
    weak var weakParent: StoriesViewController?
    var hasTopNotch: Bool = false
    var story: [String]?
    var storyBar: StoryBar!
    
    // MARK: - Methods
    func setStory(story: [String]?) {
        self.story = story
        contentView.layoutIfNeeded()
        addStoryBar()
        innerCollection.reloadData()
        innerCollection.scrollToItem(at: IndexPath(item: 0, section: 0),
                                     at: .centeredHorizontally, animated: false)
    }
    
    private func addStoryBar() {
        if storyBar != nil {
            storyBar.removeFromSuperview()
            storyBar = nil
        }
        storyBar = StoryBar(numberOfSegments: story?.count ?? 0)
        storyBar.frame = CGRect(x: 15, y: CGFloat(10), width: self.frame.width - 30, height: 4)
        storyBar.delegate = self
        storyBar.animatingBarColor = UIColor.cyan
        storyBar.nonAnimatingBarColor = UIColor.lightGray
        storyBar.padding = 2
        storyBar.resetSegmentsTill(index: 0)
        contentView.addSubview(storyBar)
    }
}

// MARK: - Segmented ProgressBar Delegate
extension OuterCell: SegmentedProgressBarProtocol {
    func segmentedProgressBarChangedIndex(_ index: Int) {
        weakParent?.currentStoryIndexChanged(index: index)
        innerCollection.scrollToItem(at: IndexPath(item: index, section: 0),
                                     at: .centeredHorizontally, animated: false)
    }
    
    func segmentedProgressBarReachEnd() {
        weakParent?.showNextUserStory()
    }
    
    func segmentedProgressBarReachPrevious() {
        weakParent?.showPreviousUserStory()
    }
}

// MARK: - Segmented ProgressBar Delegate
extension OuterCell: ImageZoomProtocol {
    func imageZoomStart() {
        storyBar.pause()
    }
    
    func imageZoomEnd() {
        storyBar.resume()
    }
}

// MARK: - Collection View Data Source and Delegate
extension OuterCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return story?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InnerCell", for: indexPath) as! InnerCell
        let data = story?[indexPath.row]
        print(story)
        cell.setImage(data ?? "", deeplink: data ?? "")
        cell.delegate = self
        return cell
    }
}
