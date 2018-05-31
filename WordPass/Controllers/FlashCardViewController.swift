//
//  FlashCardViewController.swift
//  WordPass
//
//  Created by Apple on 2018/4/18.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit
import CoreData

protocol FlashCardViewControllerDelegate: class {
    func fetchLearningData()
}

class FlashCardViewController: UIViewController {
    var cards: [Card] = [] {
        didSet {
            if !cards.isEmpty {
                let validIndex = index >= oldValue.count ? 0 : index
                embeddedCardFront?.card = cards[validIndex]
                embeddedCardBack?.card = cards[validIndex]
                if index != oldValue.count || index == 0 {
                    cardFrontView.isHidden = false
                    titleLabel.text = "单词卡片 \(index + 1)/\(cards.count)"
                }
            }
        }
    }
    var words: [Word] = [] {
        didSet {
            if !words.isEmpty{
                let validIndex = index >= oldValue.count ? 0 : index
                embeddedCardFront?.word = words[validIndex]
                embeddedCardBack?.word = words[validIndex]
            }
        }
    }
    var groupCount = 1
    var index = 0 {
        didSet {
            if index == cards.count {
                progressView.isHidden = true
                titleLabel.text = "第 \(groupCount) 组"
            } else if index > cards.count {
                index = 0
                titleLabel.text = "单词卡片 1/\(cards.count)"
            } else {
                progressView.progress = Float(index + 1) / Float(cards.count)
                titleLabel.text = "单词卡片 \(index + 1)/\(cards.count)"
                embeddedCardFront?.card = cards[index]
                embeddedCardBack?.card = cards[index]
                embeddedCardFront?.word = words[index]
                embeddedCardBack?.word = words[index]
            }
        }
    }
    var user: User!
    weak var mainScreenViewController: MainScreenViewController?
    weak var delegate: FlashCardViewControllerDelegate?
    private var record: Record? {
        get {
            let date = Date.init()
            return studyRecords.filter({$0.startingTime?.day == date.day && $0.startingTime?.month == date.month && $0.startingTime?.year == date.year}).first
        } set {
            self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
                newValue?.duration += 1
                saveContext()
            })
        }
    }
    private var studyRecords: [Record] {
        return user.studyRecords?.allObjects as! [Record]
    }
    private var timer: Timer?
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 1
        }
    }
    
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var cardFrontView: UIView!
    @IBOutlet weak var cardBackView: UIView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = .left
            cardBackView.addGestureRecognizer(swipe)
        }
    }

    @objc func nextCard() {
        switchView()
        index += 1
    }
    
    private var embeddedCardFront: CardFrontViewController?
    private var embeddedCardBack: CardBackViewController?
    private var embeddedSummaryView: SummaryViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCardFront" {
            if let destinationController = segue.destination as? CardFrontViewController {
                embeddedCardFront = destinationController
                destinationController.delegate = self
            }
        } else if segue.identifier == "showCardBack" {
            if let destinationController = segue.destination as? CardBackViewController {
                embeddedCardBack = destinationController
                destinationController.user = user
            }
        } else if segue.identifier == "showSummaryView" {
            if let destinationController = segue.destination as? SummaryViewController {
                embeddedSummaryView = destinationController
                destinationController.delegate = self
                destinationController.flashCardViewController = self
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.8)
        self.navigationItem.titleView = titleLabel
        
        if let words = mainScreenViewController?.words, let cards = mainScreenViewController?.cards {
            self.words = words
            self.cards = cards
        }
        
        progressView.progress = 1/10
        //数据没有加载完毕则隐藏卡片
        if cards.isEmpty {
            cardFrontView.isHidden = true
        }
        cardBackView.isHidden = true
        summaryView.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let date = Date.init()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            if record == nil {
                let record = Record(context: context)
                record.startingTime = date
                user.addToStudyRecords(record)
                self.record = record
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            } else {
                self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
                    self.record?.duration += 1
                    saveContext()
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
}

extension FlashCardViewController: CardFrontViewControllerDelegate, SummaryViewControllerDelegate {
    func continueLearning() {
        summaryView.isHidden = true
        cardFrontView.isHidden = false
    }
    
    func switchView() {
        if index < cards.count - 1 {
            cardFrontView.isHidden = !cardFrontView.isHidden
            cardBackView.isHidden = !cardBackView.isHidden
        } else if index == cards.count - 1{
            if cardFrontView.isHidden {
                cardBackView.isHidden = true
                summaryView.isHidden = false
                embeddedSummaryView?.words = words
                delegate?.fetchLearningData()
            } else {
                cardFrontView.isHidden = true
                cardBackView.isHidden = false
            }
        }
    }
    
    func updateModel(for word: Word, isRecognized: Bool) {
        if !word.isLearning {
            word.isLearning = true
            user.removeFromWordsNeedToLearn(word)
            user.addToLearningWords(word)
            user.addToLearnedWords(word)
            removeValueFromArray(value: word, array: &mainScreenViewController!.wordsNeedToLearn)
            mainScreenViewController?.learningWords.append(word)
        }
        if isRecognized {
            word.progress += 25
            if word.progress > 75 {
                word.isMastered = true
                user.addToMasteredWords(word)
                user.removeFromLearningWords(word)
                removeValueFromArray(value: word, array: &mainScreenViewController!.learningWords)
            }
        } else {
            word.progress += 0
        }
        
        record?.addToLearnedWords(word)
        saveContext()
    }
}

public func getRemoveIndex<T: Equatable>(_ value: T, _ array: [T]) -> Int? {
    var currentIndex: Int?
    //获取指定值在数组中的索引
    for (index,_) in array.enumerated() {
        if array[index] == value {
            currentIndex = index
            break
        }
    }
    
    return currentIndex
}

public func removeValueFromArray<T: Equatable>(value: T, array: inout [T]) {
    let index = getRemoveIndex(value, array)
    //从原数组中删除指定元素
    if let index = index {
        array.remove(at: index)
    }
}
