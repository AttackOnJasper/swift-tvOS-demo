//
//  ServiceProvider.swift
//  TopShelf
//
//  Created by Jasper Wang on 16/1/15.
//  Copyright © 2016年 Jasper. All rights reserved.
//

import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
    }
    
    // MARK: - TVTopShelfProvider protocol
    
    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .Inset
    }
    
    var topShelfItems: [TVContentItem] {
        var ContentItems = [TVContentItem]()
        
        for (var i = 0; i < 8; i++) {
            let identifier = TVContentIdentifier(identifier: "VOD", container: nil)!
            let contentItem = TVContentItem(contentIdentifier: identifier )!
            
            if let url = NSURL(string: "http://www.brianjcoleman.com/code/images/feature-\(i).jpg") {
                contentItem.imageURL = url
                contentItem.title = "Movie Title"
                contentItem.displayURL = NSURL(string: "VideoApp://video/\(i)");
                contentItem.playURL = NSURL(string: "VideoApp://video/\(i)");
            }
            
            ContentItems.append(contentItem)
        }
        
        return ContentItems
    }


}

