//
//  SummaryViewWordCell.swift
//  WordPass
//
//  Created by Apple on 2018/5/8.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class SummaryViewWordCell: UITableViewCell {

    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel! {
        didSet {
            definitionLabel.numberOfLines = 1
        }
    }
    @IBOutlet weak var progressImage: UIImageView!
    
    
}
