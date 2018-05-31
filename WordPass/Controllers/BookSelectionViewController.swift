//
//  BookSelectionTableViewController.swift
//  WordPass
//
//  Created by Apple on 12/03/2018.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit
import CoreData

class BookSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var Books: [Book] = []
    var user: User!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let request: NSFetchRequest<Book> = Book.fetchRequest()
            let context = appDelegate.persistentContainer.viewContext
            do {
                Books = try context.fetch(request)
            }
            catch{
                print("Failed to retrieve record")
                print(error)
            }
        }
        
        if !UserDefaults.standard.bool(forKey: "hasCreatedUser") {
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                user = User(context: appDelegate.persistentContainer.viewContext)
                let randomID = 1000000.randomNumber
                user.username = "用户\(randomID)"
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.set(true, forKey: "hasCreatedUser")
                print("Saving data to context")
                appDelegate.saveContext()
            }
        }
        
        tableView.sectionHeaderHeight = 30.0
        
        // 自定义导航栏背景和标题
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray,.font: UIFont(name: "Avenir", size: 18.0)!]
        navigationController?.hidesBarsOnSwipe = false
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Books.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "所有单词书(共\(Books.count)本)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.darkGray
        headerView.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Book Cell", for: indexPath) as! BookSelectionTableViewCell
        cell.thumbnail.image = UIImage(named: Books[indexPath.row].name!)
        cell.bookNameLabel.text = Books[indexPath.row].name
        cell.wordsCountLabel.text = "单词量：\(Books[indexPath.row].wordList?.count ?? 0)"
        cell.createdByLabel.text = "创建者：\(Books[indexPath.row].createdBy ?? "")"
        
        return cell
    }
    
}
