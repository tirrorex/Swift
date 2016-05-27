//
//  StatsCollectionViewCell.swift
//  Smartertime
//
//  Created by thibaut noah on 14/10/15.
//  Copyright © 2015 Smarter Time. All rights reserved.
//

import UIKit

class StatsCollectionViewCell: UICollectionViewCell {
    
    var activityNameLabel: UILabel!
    var timeLabel: UILabel!
    var activityButton: UIButton!
    var histogramView: UIView!
//    var textlabel = UILabel()
    
    override init(frame: CGRect) {
        let width = frame.size.width
        let height = frame.size.height
        activityButton = UIButton(frame: CGRectMake(0, 0, width / 9, height))
        activityNameLabel = UILabel(frame: CGRectMake(width / 9, 0, width - (width*2/9), height*2/3))
        histogramView = UIView(frame: CGRectMake(width / 9, height*2/3, width - (width*2/9), height/3))
        timeLabel = UILabel(frame: CGRectMake(width - width/9, 0, width/3, height))
//        textlabel = UILabel(frame: CGRectMake(0, 0, width,height))
        super.init(frame: frame)
        addSubview(activityButton)
        addSubview(activityNameLabel)
        addSubview(timeLabel)
        addSubview(histogramView)

    }


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
