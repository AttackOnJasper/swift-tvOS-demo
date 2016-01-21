//
//  ChannelCell.swift
//  swift-tvOS-demo
//
//  Created by Jasper Wang on 16/1/16.
//  Copyright © 2016年 Jasper. All rights reserved.
//

import Foundation
import UIKit

class ChannelCell: UICollectionViewCell {

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showSubtitleLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    
    var channel: ChannelModel? {
        didSet {
            self.updateToChannel()
        }
    }
    
    override func awakeFromNib() {
        //        self.previewImageView.adjustsImageWhenAncestorFocused = true
        //        self.layer.shadowRadius = 20
        self.updateFocusedStateUI()
        
    }
    
    override func canBecomeFocused() -> Bool {
        return true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.channel = nil
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ () -> Void in
            self.focusedState =  (context.nextFocusedView === self)
            }, completion: nil)
    }
    
    //    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
    //        NSLog("\(context)")
    //        return true
    //    }
    
    
    var focusedState: Bool = false {
        didSet {
            updateFocusedStateUI()
        }
    }
    
    func updateFocusedStateUI() {
        self.showSubtitleLabel.hidden = !self.focusedState
        self.showTitleLabel.hidden = !self.focusedState
        
        //            if self.focusedState {
        //                self.transform = CGAffineTransformMakeScale(1.1, 1.1)
        //                self.layer.shadowOpacity = 1.0
        //            } else {
        //                self.transform = CGAffineTransformMakeScale(1.0, 1.0)
        //                self.layer.shadowOpacity = 0
        //            }
        //            self.setNeedsLayout()
        //            self.layoutIfNeeded()
        
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var shadowsPath = self.bounds
        if (self.focusedState) {
            shadowsPath = shadowsPath.insetBy(dx: 20, dy: 20).offsetBy(dx: 0, dy: 20)
        }
        self.layer.shadowPath = UIBezierPath(rect: shadowsPath).CGPath
    }
    
    private func updateToChannel() {
        self.showSubtitleLabel.text = "Fake show subtitle"
        self.showTitleLabel.text = self.channel?.name
        self.previewImageView.image = self.channel?.preview
    }
    
    
}