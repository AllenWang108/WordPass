//
//  MainScreenViewController.swift
//  WordPass
//
//  Created by Apple on 17/03/2018.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit
import CoreData

class MainScreenViewController: UIViewController, FlashCardViewControllerDelegate, SWRevealViewControllerDelegate {
    
    private var learnedWords: Int?
    private var masteredWords: Int?
    private var totalWords: Int?
    private var flashCardViewController: FlashCardViewController?
    private var dataIsFetched: Bool = false
    private var coverView: UIView!
    private var masteredWordsInCurrentBook: [Word] {
        var masteredWords = [Word]()
        if let user = user {
            let words = user.learningBook?.wordList?.allObjects as! [Word]
            masteredWords = words.filter{$0.isMastered == true}
        }
        return masteredWords
    }
    
    var cards: [Card] = []
    var words: [Word] = []
    var book: Book?
    var user: User?
    
    lazy var wordsNeedToLearn: [Word] = {
        if let user = user {
            return user.wordsNeedToLearn?.allObjects as! [Word]
        } else {
            return [Word]()
        }
    }()
    lazy var learningWords: [Word] = {
        if let user = user {
            return user.learningWords?.allObjects as! [Word]
        } else {
            return [Word]()
        }
    }()
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverView = UIView(frame: self.view.frame)
        coverView.backgroundColor = .black
        coverView.alpha = 0
        
        if let navController = self.navigationController as? ITNavigationController {
            navController.addToForbiddenArray(for: ["WordListViewController", "CalendarViewController"])
        }
        
        // 如果用户不是第一次登陆，则从数据库中获取用户的数据
        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if loggedIn {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                let request: NSFetchRequest<User> = User.fetchRequest()
                let context = appDelegate.persistentContainer.viewContext
                request.fetchLimit = 1
                let username = UserDefaults.standard.string(forKey: "username")
                request.predicate = NSPredicate(format: "username == %@", username!)
                do {
                    let results = try context.fetch(request)
                    if let loggedInUser = results.first{
                        user = loggedInUser
                    }
                }
                catch {
                    print("Failed to retrieve record")
                    print(error)
                }
                
                updateUI()
            }
        }
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            revealViewController().rearViewRevealWidth = UIScreen.main.bounds.width*4/5
            revealViewController().bounceBackOnLeftOverdraw = false
            revealViewController().bounceBackOnOverdraw = false
            revealViewController().toggleAnimationType = .easeOut
            revealViewController().delegate = self
            if let rearViewController = revealViewController().rearViewController as? SidebarMenuTableViewController {
                rearViewController.user = self.user
            }
        }
    }
    
    // MARK: - SWRevealViewControllerDelegate
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        if position.rawValue == 4 {
            // 最大alpha值
            coverView.alpha = 0.3
            // 添加遮盖
            revealViewController().frontViewController.view.addSubview(coverView)
            coverView.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            coverView.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        } else {
            coverView.alpha = 0
            coverView.removeFromSuperview()
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        revealViewController().frontViewController.view.addSubview(coverView)
    }
    
    func revealController(_ revealController: SWRevealViewController!, panGestureMovedToLocation location: CGFloat, progress: CGFloat, overProgress: CGFloat) {
        coverView.alpha = progress * 0.3
    }
    
    func revealController(_ revealController: SWRevealViewController!, panGestureEndedToLocation location: CGFloat, progress: CGFloat, overProgress: CGFloat) {
        if progress <= 0.5 {
            coverView.removeFromSuperview()
        }
    }
    
    // MARK: - Customize status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {

        //判断用户是否是第一次登陆
        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if !loggedIn {
            UserDefaults.standard.set(true, forKey: "loggedIn")
        }
        
        //自定义导航栏颜色和字体
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 248.0/255.0, green: 148.0/255.0, blue: 6.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,.font: UIFont(name: "Avenir", size: 20.0)!]
        updateUI()
        
        if !dataIsFetched {
            fetchLearningData()
            dataIsFetched = true
        }
        
        //判断用户是否已经选择了单词书
        if UserDefaults.standard.bool(forKey: "hasSelectedBook") {
            return
        }
        
        //弹出选择单词书的界面
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let bookSelectionViewController = storyboard.instantiateViewController(withIdentifier: "BookSelectionViewController") as? BookSelectionViewController {
            
            present(bookSelectionViewController, animated: false, completion: nil)
        }
    }
    
    @IBOutlet weak var daysCountLabel: UILabel!
    @IBOutlet weak var selectedBookLabel: UILabel!
    @IBOutlet weak var learnedWordsLabel: UILabel!
    @IBOutlet weak var masteredWordsLabel: UILabel!
    @IBOutlet weak var mainScreenDashboardView: MainScreenDashboardView!
    
    // MARK: - FlashCardViewControllerDelegate
    func fetchLearningData() {
        cards.removeAll()
        words.removeAll()
        createCardStack()
    }
    
    // Unwind segue from BookSelectionTableViewController
    @IBAction func showMainScreen(segue: UIStoryboardSegue) {
        let sourceController = segue.source as! BookSelectionViewController
        if let indexPath = sourceController.tableView.indexPathForSelectedRow {
            UserDefaults.standard.set(true, forKey: "hasSelectedBook")
            if !UserDefaults.standard.bool(forKey: "hasCreatedUser") {
                user = sourceController.user
            }
            
            if let learningBook = user?.learningBook {
                user?.addToLearnedBooks(learningBook)
            }
            book = sourceController.Books[indexPath.row]
            user?.learningBook = book
            user?.wordsNeedToLearn = book?.wordList
            wordsNeedToLearn = book?.wordList?.allObjects as! [Word]
            updateUI()
            saveContext()
        }
    }
    
    @IBAction func switchLearningBook(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let bookSelectionViewController = storyBoard.instantiateViewController(withIdentifier: "BookSelectionViewController") as! BookSelectionViewController
        self.navigationController?.pushViewController(bookSelectionViewController, animated: true)
    }
    
    // Unwind segue from SummaryViewController
    @IBAction func takeABreak(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
        dataIsFetched = true
    }
    
    private func updateUI() {
        if let user = user {
            learnedWords = user.learnedWords?.count
            masteredWords = masteredWordsInCurrentBook.count
            totalWords = user.learningBook?.wordList?.count
        }
        daysCountLabel.text = String(user?.studyRecords?.count ?? 0)
        selectedBookLabel.text = user?.learningBook?.name
        learnedWordsLabel.text = String(learnedWords ?? 0)
        masteredWordsLabel.text = "\(masteredWords ?? 0) / \(totalWords ?? 3000)"
        mainScreenDashboardView.progress = Double(masteredWords ?? 0)/Double(totalWords ?? 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startLearningWords" {
            let destinationController = segue.destination as! FlashCardViewController
            destinationController.user = user
            flashCardViewController = destinationController
            destinationController.mainScreenViewController = self
            destinationController.delegate = self
        } else if segue.identifier == "showWordList" {
            let destinationController = segue.destination as! WordListViewController
            destinationController.user = user
            destinationController.wordsNeedToLearn = wordsNeedToLearn
            destinationController.learningWords = learningWords
        } else if segue.identifier == "showCalendar" {
            let destinationController = segue.destination as! CalendarViewController
            destinationController.user = user
        }
    }
    
    func createCardStack() {
        if learningWords.count < 50 && wordsNeedToLearn.count >= 10 {
            fetchLearningData(from: wordsNeedToLearn, count: 10, isReversed: false)
        } else if learningWords.count >= 50 || (learningWords.count < 50 && learningWords.count >= 20 && wordsNeedToLearn.count < 10) {
            let arr = [0, 25, 50, 75]
            let index = indexOfMaxValue(of: arr)
            wordsNeedToLearn.count < (user?.learningBook?.wordList?.count)!/2 ? getLearningWordsData(progress: arr[index], overhalf: true) : getLearningWordsData(progress: arr[index], overhalf: false)
        } else {
            if wordsNeedToLearn.count > 0 {
                fetchLearningData(from: wordsNeedToLearn, count: wordsNeedToLearn.count, isReversed: false)
                let count = (learningWords.count > 10 - wordsNeedToLearn.count) ? 10 - wordsNeedToLearn.count : learningWords.count
                fetchLearningData(from: learningWords, count: count , isReversed: false)
            } else {
                if learningWords.count >= 10 {
                    fetchLearningData(from: learningWords, count: 10, isReversed: false)
                } else {
                    fetchLearningData(from: learningWords, count: learningWords.count, isReversed: false)
                }
            }
        }
    }
    
    private func indexOfMaxValue(of array: [Int]) -> Int {
        var maxIndex = 0, maxValue = 0
        for (index, _) in array.enumerated() {
            let words = wordsOfProgress(array[index])
            if words.count > maxValue {
                maxIndex = index
                maxValue = words.count
            }
        }
        
        return maxIndex
    }
    
    private func getLearningWordsData(progress: Int, overhalf: Bool) {
        var arr = [0, 25, 50, 75]
        if progress != 75 {
            for (index, _) in arr.enumerated() {
                if arr[index] == progress {
                    arr.remove(at: index+1)
                    break
                }
            }
        }
        if overhalf {
            let count = (wordsNeedToLearn.count >= 2) ? 2 : wordsNeedToLearn.count
            if count > 0 {
                fetchLearningData(from: wordsNeedToLearn, count: count, isReversed: false)
            }
            for (index, _) in arr.enumerated() {
                arr[index] == progress ? getLearningWordsData(progress: progress, count: 10-count-(arr.count-1)*2) : getLearningWordsData(progress: arr[index], count: 2)
            }
        } else {
            let count = (wordsNeedToLearn.count >= 3) ? 3 : wordsNeedToLearn.count
            if count > 0 {
                fetchLearningData(from: wordsNeedToLearn, count: count, isReversed: false)
            }
            for (index, _) in arr.enumerated() {
                arr[index] == progress ? getLearningWordsData(progress: progress, count: 10-count-(arr.count-1)*1) : getLearningWordsData(progress: arr[index], count: 1)
            }
        }
    }
    
    private func getLearningWordsData(progress: Int, count: Int) {
        let arr = [0, 25, 50, 75]
        if wordsOfProgress(progress).count >= count {
            fetchLearningData(from: wordsOfProgress(progress), count: count, isReversed: false)
        } else {
            for num in arr {
                if wordsOfProgress(num).count >= count {
                    fetchLearningData(from: wordsOfProgress(num), count: count, isReversed: true)
                    break
                }
            }
        }
    }
    
    private func wordsOfProgress(_ progress: Int) -> [Word] {
        return learningWords.filter{$0.progress == progress}
    }
    
    private func fetchLearningData(from wordList: [Word], count: Int, isReversed: Bool) {
        for index in 0..<count {
            let word = isReversed ? wordList[wordList.count-1-index]: wordList[index]
            fetchLearningData(for: word)
        }
    }
    
    private func fetchLearningData(for word: Word) {
        let url = URL(string: "https://xtk.azurewebsites.net/BingDictService.aspx?Word=\(word.englishWord ?? "")")
        if let url = url {
            print(url)
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                
                if let error = error {
                    print(error)
//                    self.user?.learningBook?.removeFromWordList(word)
//                    self.user?.removeFromWordsNeedToLearn(word)
//                    let nextWord = self.wordsNeedToLearn.last
//                    if let nextWord = nextWord {
//                        self.fetchLearningData(for: nextWord)
//                    }
//
//                    saveContext()
                }
                
                if let data = data {
                    let card = self.parseJsonData(data: data)
                    if let card = card {
                        self.cards.append(card)
                        self.words.append(word)
                        print(self.cards.count)
                    }
                    
                }
                
                if self.cards.count == 10 || self.cards.count == 9 || self.cards.count == (self.wordsNeedToLearn.count + self.learningWords.count) {
                    DispatchQueue.main.async {
                        self.flashCardViewController?.cards = self.cards
                        self.flashCardViewController?.words = self.words
                        self.dataIsFetched = false
                    }
                }
            })
            task.resume()
        }
    }
    
    private func parseJsonData(data: Data) -> Card? {
        var card: Card?
        
        let decoder = JSONDecoder()
        do {
            let learningCard = try decoder.decode(Card.self, from: data)
            card = learningCard
        } catch {
            print(error)
        }
        
        return card
    }
}

public func saveContext() {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        let context = appDelegate.persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


