//
//  MainViewController.swift
//  swift-tvOS-demo
//
//  Created by Jasper Wang on 15/12/28.
//  Copyright © 2015年 Jasper. All rights reserved.
//

import UIKit
import AVKit

let channelList = [
    "a","b","c","d","e","f","g"
]

func randomStreamUrl() -> NSURL {
    let files = ["video1", "video2", "niagara"]
    let fileName = files[Int(arc4random_uniform(UInt32(files.count)))]
    return NSBundle.mainBundle().URLForResource(fileName, withExtension: "mp4")!
}

let TestChannels = channelList.map { name in
    ChannelModel(name: name, preview: UIImage(named: "sample"), url: "", streamUrl: randomStreamUrl())
}



class FocusableEmptyView: UIView {
    var focusable = true
    override func canBecomeFocused() -> Bool {
        return focusable
    }
}

enum MainNavigationMode { case Video, Swimlane, HeadOverlay }

class MainViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    let allChannels: [ChannelModel] = TestChannels
    
    @IBOutlet weak var networksSwimlaneContainerView: UIView!
    @IBOutlet weak var networksSwimlaneControllerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainFocusGuideContainerView: UIView!
    @IBOutlet weak var headOverlayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headOverlayView: FocusableEmptyView!
    @IBOutlet weak var headOverlayFadeImageView: UIImageView!
    @IBOutlet weak var menuSwipeDownView: FocusableEmptyView!
    @IBOutlet weak var bottomFadeView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var overlayImageView: UIImageView!
    
    @IBOutlet weak var dockToPIPButton: UIButton!
    @IBOutlet weak var avPlayerLayerContainer: UIView!
    var playerLayer: AVPlayerLayer! = nil

    @IBOutlet weak var menuButtonsContainer: UIStackView!
    var tapGestureRec: UITapGestureRecognizer = UITapGestureRecognizer()
    
    
    var navigationState: MainNavigationMode = .Video {
        didSet {
            if self.isViewLoaded() {
                updateUIState(animated: true)
            }
            self.setNeedsFocusUpdate()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapped"))
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.Menu.rawValue)];
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        self.updateUIState(animated: false)
        
        setupFocusGuides()
        
        setupDefaultPlayback()
        self.headOverlayFadeImageView.transform = CGAffineTransformMakeScale(1, -1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer.frame = self.avPlayerLayerContainer.bounds
    }

    func setupFocusGuides() {
        let topFocusGuide = UIFocusGuide()
        self.view.addLayoutGuide(topFocusGuide)
        
        topFocusGuide.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        topFocusGuide.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        topFocusGuide.bottomAnchor.constraintEqualToAnchor(self.headOverlayView.topAnchor).active = true
        topFocusGuide.heightAnchor.constraintEqualToConstant(40).active = true
        topFocusGuide.preferredFocusedView = self.mainFocusGuideContainerView
    }
    
    
    func setupDefaultPlayback() {
        let player = AVPlayer(URL: NSBundle.mainBundle().URLForResource("niagara", withExtension: "mp4")!)
        self.playerLayer = AVPlayerLayer(player: player)
        self.avPlayerLayerContainer.layer.addSublayer(self.playerLayer)
        self.playerLayer.player?.play()
        self.updateHeadOverlay(self.allChannels.first!)
    }
    
    func playMainChannel(channel: ChannelModel) {
        self.playerLayer.player?.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: channel.streamUrl))
        self.playerLayer.player?.play()
    }
    
    func updateHeadOverlay(channel: ChannelModel) {
        self.showTitleLabel.text = channel.name
        self.episodeNameLabel.text = "Season and episode hardcoded"
        self.descriptionLabel.text = "Some very very long and informative episode description."
        self.overlayImageView.image = channel.preview
    }
    
    //MARK: - Customzing Focus engine
    
    func tapped(){
        if self.navigationState == .Swimlane{
            self.navigationState = .Video
        }
    }

    override var preferredFocusedView: UIView? {
        switch self.navigationState {
        case .Swimlane:
            return self.networksSwimlaneContainerView.preferredFocusedView
        case .HeadOverlay:
            return self.headOverlayView
        default:
            return self.mainFocusGuideContainerView
        }
    }
    
    var navigationDisabled: Bool = false
    
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {

        
        if  context.nextFocusedView == .Some(self.mainFocusGuideContainerView) {
            if self.navigationState == .HeadOverlay && context.focusHeading == .Up {
                
                self.navigationState = .Video
                self.navigationDisabled = true

                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    self.navigationDisabled = false
                }

            } else {
                return false
            }
        } else if context.previouslyFocusedView == .Some(self.mainFocusGuideContainerView) {
            if self.navigationDisabled { return false }
            if context.focusHeading == .Up {
                self.navigationState = .Swimlane
            }
            if context.focusHeading == .Down {
                self.navigationState = .HeadOverlay
                self.headOverlayView.focusable = false
                self.setNeedsFocusUpdate()
                return false
            }
        }

        return true
    }

    @IBAction func mainViewClicked(sender: AnyObject) {
        self.navigationState = .Swimlane
    }
    
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allChannels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("channelCell", forIndexPath: indexPath) as! ChannelCell
        cell.channel = self.allChannels[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.mainPlayingChannel = self.allChannels[indexPath.row]
        
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceivePress press: UIPress) -> Bool {
        return self.navigationState == .Swimlane
    }
    
    
    //MARK: - Internal state update
    
    func updateUIState(animated animate: Bool) {
        let adjustUIState = {
            switch self.navigationState {
            case .Video:
                self.menuButtonsContainer.alpha = 0
                self.bottomFadeView.alpha = 0
            case .Swimlane:
                self.menuButtonsContainer.alpha = 1
                self.bottomFadeView.alpha = 1
            case .HeadOverlay:
                self.menuButtonsContainer.alpha = 0
                self.bottomFadeView.alpha = 0
            }
        }
        
        switch self.navigationState {
        case .Video:
            self.networksSwimlaneControllerBottomConstraint.constant = -self.networksSwimlaneContainerView.frame.height
            self.headOverlayTopConstraint.constant = -self.headOverlayView.frame.height
        case .Swimlane:
            self.networksSwimlaneControllerBottomConstraint.constant = 0
            self.headOverlayTopConstraint.constant = -self.headOverlayView.frame.height
        default:
            self.networksSwimlaneControllerBottomConstraint.constant = -self.networksSwimlaneContainerView.frame.height
            self.headOverlayTopConstraint.constant = 0
        }
        
        if (animate) {
            UIView.animateWithDuration(0.2) {
                self.view.layoutIfNeeded()
                adjustUIState()
            }
            
        } else {
            adjustUIState()
        }
    }
    
    //MARK: - Navigation handling
    
    @IBAction func recommendedPressed(sender: AnyObject) {
    }
    
    @IBAction func favoritesPressed(sender: AnyObject) {
    }

    
    @IBAction func allNetworksPressed(sender: AnyObject) {
    }

    
    @IBAction func categoriesPressed(sender: AnyObject) {
    }

    @IBAction func fullGuidePressed(sender: AnyObject) {
    }

    
    var mainPlayingChannel: ChannelModel! = nil {
        didSet {
            playMainChannel(self.mainPlayingChannel)
            updateHeadOverlay(self.mainPlayingChannel)
        }
    }
    
}

