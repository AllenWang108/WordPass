//
//  BookSelectionTableViewCell.swift
//  WordPass
//
//  Created by Apple on 12/03/2018.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class BookSelectionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            thumbnail?.layer.shadowColor = UIColor.black.cgColor
            thumbnail?.layer.shadowOffset = CGSize(width: 0, height: 0)
            thumbnail?.layer.shadowOpacity = 0.4
            thumbnail?.layer.shadowRadius = 5
        }
    }
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    
}
