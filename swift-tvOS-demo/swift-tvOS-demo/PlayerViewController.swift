//
//  PlayerViewController.swift
//  swift-tvOS-demo
//
//  Created by Jasper Wang on 15/12/28.
//  Copyright © 2015年 Jasper. All rights reserved.
//

import UIKit
import AVKit

class PlayerViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        player = AVPlayer(URL: NSURL(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!)
        player?.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
