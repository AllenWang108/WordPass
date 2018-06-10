//
//  CardDetailSampleCell.swift
//  WordPass
//
//  Created by Apple on 2018/5/1.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit
import AVFoundation

class CardDetailSampleCell: UITableViewCell {
    var audioURL: URL?
    var shouldReloadAudioData: Bool!
    var indexPath: IndexPath!
    var audioPlayer: AVAudioPlayer?
    
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
        if audioURL != nil && shouldReloadAudioData {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: (self?.audioURL)!)
                DispatchQueue.main.async {
                    if let audioData = urlContents {
                        
                        do {
                            self?.audioPlayer = try AVAudioPlayer(data: audioData)
                            self?.shouldReloadAudioData = false
                            if self?.audioPlayer != nil {
                                self?.playAudio(with: (self?.audioPlayer)!)
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        } else if !shouldReloadAudioData, let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            } else {
                playAudio(with: audioPlayer)
            }
        }
    }
    
    func playAudio(with audioPlayer: AVAudioPlayer) {
        audioPlayer.play()
        // 发送通知让tableView停止其它正在播放的音频
        NotificationCenter.default.post(name: .WPPlayAudio, object: self, userInfo: ["indexPath": indexPath])
    }
}
