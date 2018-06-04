//
//  CardFrontViewController.swift
//  WordPass
//
//  Created by Apple on 2018/4/25.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

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
    private var audioPlayer: AVAudioPlayer!
    private var shouldReloadAudioData: Bool = true
    
    weak var delegate: CardFrontViewControllerDelegate?
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var coolButton: UIButton!
    @IBOutlet weak var phoneticButton: UIButton!
    @IBOutlet weak var sadButton: UIButton!
    
    // 不认识该单词
    @IBAction func sadButton(_ sender: UIButton) {
        if let word = word {
            shouldReloadAudioData = true
            delegate?.switchView()
            delegate?.updateModel(for: word, isRecognized: false)
        }
    }
    
    // 播放声音
    @IBAction func phoneticButton(_ sender: UIButton) {
        let url = URL(string: card?.pronunciation ?? "")
        if url != nil && shouldReloadAudioData {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    if let audioData = urlContents, url == URL(string: (self?.card?.pronunciation)!) {
            
                        do {
                            self?.audioPlayer = try AVAudioPlayer(data: audioData)
                            self?.shouldReloadAudioData = false
                            self?.audioPlayer.play()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        } else {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            } else {
                audioPlayer.play()
            }
        }
    }
    
    // 认识该单词
    @IBAction func coolButton(_ sender: UIButton) {
        if let word = word {
            shouldReloadAudioData = true
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
