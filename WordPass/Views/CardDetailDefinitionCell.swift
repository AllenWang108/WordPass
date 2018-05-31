//
//  CardDetailDefinitionCell.swift
//  WordPass
//
//  Created by Apple on 2018/5/1.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class CardDetailDefinitionCell: UITableViewCell {

    @IBOutlet weak var phoneticLabel: UILabel!
    
    @IBOutlet weak var cnDefinitionLabel: UILabel! {
        didSet {
            cnDefinitionLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var enDefinitionLabel: UILabel! {
        didSet {
            enDefinitionLabel.numberOfLines = 0
        }
    }
}
