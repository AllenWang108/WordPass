//
//  SummaryViewController.swift
//  WordPass
//
//  Created by Apple on 2018/5/8.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

protocol SummaryViewControllerDelegate: class {
    func continueLearning()
}

class SummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var words = [Word]() {
        didSet {
            tableView.reloadData()
        }
    }
    weak var delegate: SummaryViewControllerDelegate?
    weak var flashCardViewController: FlashCardViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 30
        tableView.allowsSelection = false
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var takeBreakButton: UIButton! {
        didSet {
            takeBreakButton.layer.cornerRadius = 17
            takeBreakButton.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var anotherGroupButton: UIButton! {
        didSet {
            anotherGroupButton.layer.cornerRadius = 17
            anotherGroupButton.layer.masksToBounds = true
        }
    }
    @IBAction func anotherGroupButton(_ sender: UIButton) {
        delegate?.continueLearning()
        flashCardViewController?.index += 1
        flashCardViewController?.groupCount += 1
    }
    
    // MARK: - UITableViewDateSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word Cell", for: indexPath) as! SummaryViewWordCell
        
        if !words.isEmpty {
            cell.wordLabel.text = words[indexPath.row].englishWord
            cell.definitionLabel.text = words[indexPath.row].definition
            cell.progressImage.image = UIImage(named: "\(words[indexPath.row].isMastered ? 100 : words[indexPath.row].progress)%")
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.backgroundView?.backgroundColor = UIColor.white
        headerView.textLabel?.textColor = UIColor.darkGray
        headerView.textLabel?.font = UIFont(name: "Avenir", size: 20.0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your progress this round: "
    }
}
