//
//  StoriesViewController.swift
//  OpenBook
//
//  Created by Pallavi Anant Dipke on 15/06/21.
//  Copyright © 2021 Open Digi Technologies Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

protocol ImageZoomProtocol: AnyObject {
    func imageZoomStart()
    func imageZoomEnd()
}

class InnerCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var scrollV: UIScrollView!
    @IBOutlet private weak var imgStory: UIImageView!
    @IBOutlet private weak var clickHereButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: ImageZoomProtocol?
    private var isImageDragged: Bool = false
    private var deeplink: String?
    
    // MARK: - View life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    // MARK: - Methods
    private func initialSetup() {
        scrollV.maximumZoomScale = 3.0
        scrollV.minimumZoomScale = 1.0
        scrollV.clipsToBounds = true
        scrollV.delegate = self
        scrollV.addSubview(imgStory)
    }
    
    // MARK: - Button Actions
    @IBAction func clickHereButtonTapped(_ sender: UIButton) {
        
        // TODO: -- CLICK HERE NAVIGATION
    }
}

// MARK: - Helper Methods
extension InnerCell {
    func setImage(_ image: String, deeplink: String?) {
        let gif = image.components(separatedBy: ".")
        if gif.last == ".gif" {
            guard let videoString = Bundle.main.path(forResource: gif.first, ofType: gif.last) else {
                return
            }
            let path = URL(fileURLWithPath: videoString)
            imgStory.sd_setImage(with: path, completed: nil)
        } else {
            imgStory.image = UIImage(named: image)
        }
        isImageDragged = false
        setContentMode()
        guard let deeplink = deeplink else {
            clickHereButton.isHidden = true
            return
        }
        clickHereButton.isHidden = false
        clickHereButton.isEnabled = true
        self.deeplink = deeplink
        
    }
    
    private func setContentMode() {
        if imgStory.image?.imageOrientation == .up {
            imgStory.contentMode = .scaleAspectFit
        } else if imgStory.image?.imageOrientation == .left || imgStory.image?.imageOrientation == .right {
            imgStory.contentMode = .scaleAspectFit
        }
    }
    
    private func resetImage() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scrollV.zoomScale = 1.0
        } completion: { [weak self] (isAnimationDone) in
            if isAnimationDone {
                self?.delegate?.imageZoomEnd()
                self?.isImageDragged = false
            }
        }
    }
}

// MARK: - Scroll View Data Source and Delegate
extension InnerCell: UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.imageZoomStart()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isImageDragged = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgStory
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if !isImageDragged {
            resetImage()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        resetImage()
    }
}
