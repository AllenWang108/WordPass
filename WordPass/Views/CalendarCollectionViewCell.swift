//
//  CalendarCollectionViewCell.swift
//  WordPass
//
//  Created by Apple on 2018/5/16.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var roundedBackgroundView: UIView! {
        didSet {
            roundedBackgroundView.layer.cornerRadius = roundedBackgroundView.bounds.width/2
            roundedBackgroundView.layer.masksToBounds = true
        }
    }
}
