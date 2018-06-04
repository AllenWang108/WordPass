//
//  WordListViewController.swift
//  WordPass
//
//  Created by Apple on 2018/5/10.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class WordListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //当前选中下标
    private var currentIndex = 0 {
        didSet {
            wordsCountLabel.text = "单词数：\(count)"
            currentWordList = wordListArray[currentIndex]
            tableView.reloadData()
        }
    }
    
    //存放单词列表的数组
    private var wordListArray: [[Word]] {
        return [learningWords, wordsNeedToLearn, savedWords, masteredWords]
    }
    
    //当前选中单词列表中单词的数量
    private var count: Int {
        return wordListArray[currentIndex].count
    }
    
    //当前选中的单词列表
    private var currentWordList = [Word]()
    
    var user: User!
    var learningWords: [Word] = []
    var wordsNeedToLearn: [Word] = []
    private lazy var savedWords: [Word] = {
        return user.savedWords?.allObjects as! [Word]
    }()
    private lazy var masteredWords: [Word] = {
        return user.masteredWords?.allObjects as! [Word]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.8)
        self.navigationItem.titleView = segmentControlView
//        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "返回")
        wordsCountLabel.text = "单词数：\(count)"
        currentWordList = wordListArray[currentIndex]
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10.0))
        headerView.backgroundColor = #colorLiteral(red: 0.9131317139, green: 0.9077036381, blue: 0.917304337, alpha: 1)
        tableView.tableHeaderView = headerView
        tableView.backgroundView = emptyWordView
        tableView.backgroundView?.isHidden = true
    }
    
    @IBOutlet weak var emptyWordView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var segmentControlView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet var wordListButtons: [UIButton]! {
        didSet {
            for (index, button) in wordListButtons.enumerated() {
                button.setTitleColor(#colorLiteral(red: 0.9725490196, green: 0.5803921569, blue: 0.02352941176, alpha: 1), for: .selected)
                button.backgroundColor = UIColor.white
                button.addTarget(self, action: #selector(switchList), for: .touchUpInside)
                button.tag = index
            }
            wordListButtons[0].isSelected = true
        }
    }
    
    // 切换单词列表
    @objc func switchList(sender: UIButton) {
        let index = sender.tag
        let selectedButton = wordListButtons[index]
        let previousButton = wordListButtons[currentIndex]
        selectedButton.backgroundColor = UIColor.white
        selectedButton.isSelected = true
        previousButton.isSelected = false
        if index > currentIndex {
            performAnimations(transition: kCATransitionFromRight)
        } else {
            performAnimations(transition: kCATransitionFromLeft)
        }
        currentIndex = index
        
        UIView.animate(withDuration: 0.15, animations: {
            var center = self.bottomLineView.center
            center.x = selectedButton.center.x
            self.bottomLineView.center = center
        }, completion: nil)
    }
    
    // 动画过渡效果
    func performAnimations(transition: String) {
        let caTranstion = CATransition.init()
        caTranstion.duration = 0.2
        caTranstion.type = kCATransitionPush
        caTranstion.subtype = transition
        self.tableView.layer.add(caTranstion, forKey: nil)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if currentWordList.count > 0 {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
        } else {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .none
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word Cell", for: indexPath) as! WordListDefinitionCell
        cell.wordLabel.text = currentWordList[indexPath.row].englishWord
        cell.definitionLabel.text = currentWordList[indexPath.row].definition
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var swipeConfiguration = UISwipeActionsConfiguration()
        let word = currentWordList[indexPath.row]
        if currentIndex != 2 && word.isSaved == false{
            let saveAction = UIContextualAction(style: .normal, title: "收藏") { (action, sourceView, completionHandler) in
                word.isSaved = true
                self.user.addToSavedWords(word)
                self.savedWords.append(word)
                
                //Call completion handler to dismiss the action button
                completionHandler(true)
            }
            saveAction.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.5803921569, blue: 0.02352941176, alpha: 1)
            swipeConfiguration = UISwipeActionsConfiguration(actions: [saveAction])
        } else {
            let recallAction = UIContextualAction(style: .normal, title: "取消收藏") { (action, sourceView, completionHandler) in
                word.isSaved = false
                self.user.removeFromSavedWords(word)
                removeValueFromArray(value: word, array: &self.savedWords)
                if self.currentIndex == 2 {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }

                completionHandler(true)
            }
            recallAction.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.5803921569, blue: 0.02352941176, alpha: 1)
            swipeConfiguration = UISwipeActionsConfiguration(actions: [recallAction])
        }
        return swipeConfiguration
    }
}

extension UIColor {
    var imageWithColor: UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(self.cgColor)
            context.fill(rect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
