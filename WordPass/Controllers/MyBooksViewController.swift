//
//  MyBooksViewController.swift
//  WordPass
//
//  Created by Apple on 2018/5/30.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class MyBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bookSelectionButton: UIBarButtonItem!
    @IBOutlet weak var emptyBookView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.8)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray,.font: UIFont(name: "Avenir", size: 18.0)!]
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.sectionFooterHeight = 10.0
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        bookSelectionButton.target = self
        bookSelectionButton.action = #selector(selectBook)
    }
    
    @objc private func selectBook() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let bookSelectionViewController = storyboard.instantiateViewController(withIdentifier: "BookSelectionViewController") as? BookSelectionViewController {
            self.navigationController?.pushViewController(bookSelectionViewController, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "learningBookCell", for: indexPath) as! LearningBookTableViewCell
            cell.bookNameLabel.text = user.learningBook?.name
            cell.creatorLabel.text = "创建者：\(user.learningBook?.createdBy ?? "WordPass")"
            cell.wordsCountLabel.text = "\(user.learningBook?.wordList?.count ?? 0)词"
            cell.thumbnail.image = UIImage(named: (user.learningBook?.name)!)
            if let words = user.learningBook?.wordList?.allObjects as? [Word] {
                let progress = Double(words.filter({$0.isMastered == true}).count)/Double(words.count)
                cell.currentProgressLabel.text = "当前进度：\(progress.roundTo(place: 2))%"
            } else {
                cell.currentProgressLabel.text = "当前进度：0%"
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "learnedBooksCell", for: indexPath) as! LearnedBooksTableViewCell
            cell.user = self.user
            cell.collectionView.backgroundView = emptyBookView
            cell.backgroundView?.isHidden = true
            cell.collectionView.reloadData()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return " "
        default:
            return nil
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footerView = view as! UITableViewHeaderFooterView
        switch section {
        case 0:
            footerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.8959601521, green: 0.8906343579, blue: 0.900054276, alpha: 1)
        default:
            return
        }
    }
}


extension Double {
    // 取小数点后的几位有效数字
    public func roundTo(place: Int) -> Double {
        let divisor = pow(10.0, Double(place))
        return (self * divisor).rounded()/divisor
    }
}
