//
//  CustomViewCell.swift
//  Smartertime
//
//  Created by thibaut noah on 07/09/15.
//  Copyright © 2015 web-improving. All rights reserved.
//

import UIKit

class CustomViewCell: UITableViewCell {
    
    var label: UILabel!
    var labelBis: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        //        let screenHeight = screenSize.height
        label = UILabel(frame: CGRectMake(20, 0, screenWidth / 2, 44))
        labelBis = UILabel(frame: CGRectMake(20, 20, screenWidth - 20, 20))
        labelBis.textAlignment = NSTextAlignment.Center
        self.contentView.addSubview(label)
        self.contentView.addSubview(labelBis)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.label.text = nil
        print("echo")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
