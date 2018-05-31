//
//  SidebarMenuViewController.swift
//  WordPass
//
//  Created by Apple on 2018/5/23.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class SidebarMenuTableViewController: UITableViewController {
    // MARK: - Properties and outlets
    private var sectionContent: [[String]] = [["我的单词书", "我的收藏", "我的徽章"], ["意见反馈", "给个好评", "设置"]]
    private var indexOfSelectedRow: IndexPath!
    var user: User?

    @IBOutlet weak var padding: NSLayoutConstraint!
    @IBOutlet weak var trailingDistance: NSLayoutConstraint!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var learnedDaysLabel: UILabel!
    @IBOutlet weak var learnedWordsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = 25.0
            avatarImageView.layer.masksToBounds = true
            avatarImageView.image = UIImage(named: "avatar")
        }
    }
    @IBOutlet weak var clearView: UIView!
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trailingDistance.constant = UIScreen.main.bounds.width/5 + 40
        padding.constant = UIScreen.main.bounds.width/5 - 8
        headerImageView.image = UIImage(named: "背景")
        
        tableView.sectionFooterHeight = 1
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if user != nil {
            learnedDaysLabel.text = String(user!.studyRecords?.count ?? 0)
            learnedWordsLabel.text = String(user!.learnedWords?.count ?? 0)
            usernameLabel.text = user!.nickname != nil ? user!.nickname : user!.username
            if let avatar = user?.avatar {
                avatarImageView.image = UIImage(data: avatar as Data)
            }
        }
    }
    
    // MARK: - Customize status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionContent.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionContent[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Title Cell", for: indexPath) as! SidebarMenuTableViewCell
        cell.iconImageView.image = UIImage(named: sectionContent[indexPath.section][indexPath.row])
        cell.optionLabel.text = sectionContent[indexPath.section][indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return " "
        default:
            return nil
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footerView = view as! UITableViewHeaderFooterView
        switch section {
        case 0:
            footerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexOfSelectedRow = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Unwind segue from UserInfoTableViewController
    @IBAction func backToSidebar(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserInfo" {
            if let destinationController = segue.destination.contents as? UserInfoTableViewController {
                destinationController.user = self.user
            }
        } else if segue.identifier == "showMyBooks" {
            if let destinationController = segue.destination.contents as? MyBooksViewController {
                destinationController.user = self.user
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showUserInfo" {
            return true
        } else if identifier == "showMyBooks" && sender as? SidebarMenuTableViewCell != nil {
            return true
        } else {
            return false
        }
    }
}

//MARK: - Extension
//如果是navigation controller，其contents属性为它的visbleViewController，否则为它自己
extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}
