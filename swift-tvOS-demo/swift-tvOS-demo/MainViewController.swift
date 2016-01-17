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

let processedChannelList = channelList.map {
    name in ChannelModel(name: name, preview: UIImage(named: name), url: "",  streamUrl: randomStreamUrl())
}

enum MainNavigationMode { case Video, HeadOverlay }

class FocusableEmptyView: UIView {
    var focusable = true
    override func canBecomeFocused() -> Bool {
        return focusable
    }
}

class MainViewController: AVPlayerViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    var playerLayer: AVPlayerLayer! = nil
    var mainPlayingChannel: ChannelModel! = nil {
        didSet {
            playMainChannel(self.mainPlayingChannel)
        }
    }
    
    @IBOutlet weak var headOverlayView: FocusableEmptyView!
    @IBOutlet weak var avPlayerLayerContainer: UIView!
    
    let allChannels: [ChannelModel] = processedChannelList

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        player = AVPlayer(URL: NSBundle.mainBundle().URLForResource("niagara", withExtension: "mp4")!)
        player?.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playMainChannel(channel: ChannelModel) {
        self.playerLayer.player?.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: channel.streamUrl))
        self.playerLayer.player?.play()
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
    
    


}
