//
//  CardDetailSampleCell.swift
//  WordPass
//
//  Created by Apple on 2018/5/1.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class CardDetailSampleCell: UITableViewCell {

    @IBOutlet weak var sampleSentenceLabel: UILabel! {
        didSet {
            sampleSentenceLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var translationLabel: UILabel! {
        didSet {
            translationLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var soundButton: UIButton!
    @IBAction func soundButton(_ sender: UIButton) {
        
    }
    
}
