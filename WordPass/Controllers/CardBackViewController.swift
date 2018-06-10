//
//  CardBackViewController.swift
//  WordPass
//
//  Created by Apple on 2018/4/28.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class CardBackViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var card: Card?
    var word: Word? {
        didSet {
            if let word = word {
                if word.isSaved {
                    saveButton.setImage(UIImage(named: "已收藏"), for: .normal)
                } else {
                    saveButton.setImage(UIImage(named: "收藏"), for: .normal)
                }
                if word.isMastered {
                    masterButton.setImage(UIImage(named: "已掌握"), for: .normal)
                } else {
                    masterButton.setImage(UIImage(named: "完成"), for: .normal)
                }
                updateUI()
            }
        }
    }
    var user: User!
    var shouldReloadAudioData: Bool = true
    weak var delegate: CardFrontViewControllerDelegate?
    private var audioPlayer: AVAudioPlayer!
    
    // MARK: - Outlets and actions
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var masterButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // 当前单词已掌握
    @IBAction func masterButton(_ sender: UIButton) {
        if let word = word {
            if !word.isMastered {
                masterButton.setImage(UIImage(named: "已掌握"), for: .normal)
                user.addToMasteredWords(word)
                user.removeFromLearningWords(word)
                word.isMastered = true
            } else {
                masterButton.setImage(UIImage(named: "完成"), for: .normal)
                user.removeFromMasteredWords(word)
                user.addToLearningWords(word)
                word.isMastered = false
            }
        }
        saveContext()
    }
    
    // 收藏单词
    @IBAction func saveButton(_ sender: UIButton) {
        if let word = word {
            if !word.isSaved {
                saveButton.setImage(UIImage(named: "已收藏"), for: .normal)
                user.addToSavedWords(word)
                word.isSaved = true
            } else {
                saveButton.setImage(UIImage(named: "收藏"), for: .normal)
                user.removeFromSavedWords(word)
                word.isSaved = false
            }
        }
        saveContext()
    }
    
    // 添加笔记
    @IBAction func noteButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let newNoteViewController = storyboard.instantiateViewController(withIdentifier: "NewNoteTextViewController") as? NewNoteTextViewController {
            let section = word?.note != nil ? 2 : 1
            stopPlayingAudio(forCellsAt: section)
            newNoteViewController.word = self.word
            newNoteViewController.noteContent = word?.note
            self.navigationController!.pushViewController(newNoteViewController, animated: true)
        }
    }
    
    // 播放单词的读音
    @IBAction func soundButton(_ sender: UIButton) {
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
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem?.title = " "
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionFooterHeight = 10
        tableView.separatorStyle = .none
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20.0))
        footerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = footerView
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayingAudio(with:)), name: .WPPlayAudio, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // 当有一个audioPlayer在播放声音时停止其它的播放
    @objc func stopPlayingAudio(with notification: Notification) {
        guard let userInfo = notification.userInfo, let indexPath = userInfo["indexPath"] as? IndexPath else {
            return
        }

        stopPlayingAudio(forCellsAt: indexPath.section, exceptForCellAt: indexPath.row)
    }
    
    private func stopPlayingAudio(forCellsAt section: Int, exceptForCellAt row: Int = -1) {
        guard let samples = card?.samples else {
            return
        }
        
        for index in 1...samples.count {
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: section)) as? CardDetailSampleCell, let audioPlayer = cell.audioPlayer {
                if cell.indexPath.row != row && audioPlayer.isPlaying {
                    audioPlayer.stop()
                }
            }
        }
    }
    
    // MARK: - Update UI
    private func updateUI() {
        if let word = word {
            let section = word.note != nil ? 2 : 1
            wordLabel.text = word.englishWord
            tableView.reloadData()
            stopPlayingAudio(forCellsAt: section)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return word?.note != nil ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if word?.note == nil {
            switch section {
            case 0:
                numberOfRows = 1
            default:
                if let card = card {
                    if card.samples != nil {
                        numberOfRows = card.samples!.count > 3 ? 4 : card.samples!.count + 1
                    } else {
                        numberOfRows = 2
                    }
                }
            }
        } else {
            switch section {
            case 0:
                numberOfRows = 1
            case 1:
                numberOfRows = 2
            default:
                if let card = card {
                    if card.samples != nil {
                        numberOfRows = card.samples!.count > 3 ? 4 : card.samples!.count + 1
                    } else {
                        numberOfRows = 2
                    }
                }
            }
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return " "
        case 1:
            return word?.note != nil ? " " : nil
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Definition Cell", for: indexPath) as! CardDetailDefinitionCell
            if let card = card, let word = word {
                cell.phoneticLabel.text = "[\(card.phoneticAm ?? card.phoneticBr ?? " ")]"
                if !card.definition.isEmpty {
                    var str = ""
                    for index in 0...card.definition.count - 2 {
                        str += (card.definition[index].type + " " + card.definition[index].meaning + "；")
                    }
                    let endIndex = str.endIndex
                    str.remove(at: str.index(before: endIndex))
                    cell.cnDefinitionLabel.text = str.replacingOccurrences(of: "）", with: ")").replacingOccurrences(of: "（", with: "(")
                    cell.enDefinitionLabel.text = "网络释义：\(card.definition.last!.meaning)"
                } else {
                    cell.cnDefinitionLabel.text = word.definition
                    cell.enDefinitionLabel.text = "暂无英文释义"
                }
            }
            
            return cell
        case (word?.note != nil ? 2 : 1):
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Title Cell", for: indexPath) as! CardDetailTitleCell
                cell.titleLabel.text = "例句"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Sample Cell", for: indexPath) as! CardDetailSampleCell
                if let card = card {
                    if card.samples != nil {
                        cell.translationLabel.isHidden = false
                        cell.soundButton.isHidden = false
                        cell.separatorView.isHidden = false
                        cell.sampleSentenceLabel.text = card.samples![indexPath.row - 1].englishSentence
                        cell.translationLabel.text = card.samples![indexPath.row - 1].chineseTranslation
                        cell.audioURL = URL(string: card.samples![indexPath.row - 1].mp3Url ?? "")
                        cell.shouldReloadAudioData = true
                        cell.indexPath = indexPath
                    } else {
                        cell.sampleSentenceLabel.text = "暂无例句"
                        cell.translationLabel.isHidden = true
                        cell.separatorView.isHidden = true
                        cell.soundButton.isHidden = true
                    }
                }
                
                return cell
            }
        default:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Title Cell", for: indexPath) as! CardDetailTitleCell
                cell.titleLabel.text = "笔记"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Sample Cell", for: indexPath) as! CardDetailSampleCell
                cell.sampleSentenceLabel.text = word?.note
                cell.translationLabel.isHidden = true
                cell.soundButton.isHidden = true
                cell.separatorView.isHidden = true
                return cell
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        let footerView = view as! UITableViewHeaderFooterView
        switch section {
        case 0:
            footerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        case 1:
            if word?.note != nil {
                footerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            }
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if word?.note != nil {
            switch indexPath.section {
            case 1:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let newNoteViewController = storyboard.instantiateViewController(withIdentifier: "NewNoteTextViewController") as? NewNoteTextViewController {
                    
                    newNoteViewController.word = self.word
                    newNoteViewController.noteContent = word?.note
                    self.navigationController!.pushViewController(newNoteViewController, animated: true)
                }
            default:
                return
            }
        }
    }
}
