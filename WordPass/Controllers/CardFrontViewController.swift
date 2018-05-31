//
//  CardFrontViewController.swift
//  WordPass
//
//  Created by Apple on 2018/4/25.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit
import CoreData

protocol CardFrontViewControllerDelegate: class {
    func switchView()
    func updateModel(for word: Word, isRecognized: Bool)
}

class CardFrontViewController: UIViewController {
    var card: Card? {
        didSet{
            updateUI()
        }
    }
    var word: Word?
    
    weak var delegate: CardFrontViewControllerDelegate?
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var coolButton: UIButton!
    @IBOutlet weak var phoneticButton: UIButton!
    @IBOutlet weak var sadButton: UIButton!
    
    @IBAction func sadButton(_ sender: UIButton) {
        if let word = word {
            delegate?.switchView()
            delegate?.updateModel(for: word, isRecognized: false)
        }
    }
    
    @IBAction func phoneticButton(_ sender: UIButton) {
        
    }
    
    @IBAction func coolButton(_ sender: UIButton) {
        if let word = word {
            delegate?.switchView()
            delegate?.updateModel(for: word, isRecognized: true)
        }
    }
    
    private func updateUI() {
        if let card = card {
            wordLabel.text = card.word
            phoneticButton.setTitle(" [\(card.phoneticAm ?? card.phoneticBr ?? " ")]", for: .normal)
        }
    }
}
