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
    
    
    // MARK: - Properties
    
    // 已经学习的单词个数
    private var learnedWords: Int?
    // 已经掌握的单词个数
    private var masteredWords: Int?
    // 当前单词书的总单词数
    private var totalWords: Int?
    private var flashCardViewController: FlashCardViewController?
    private var dataIsFetched: Bool = false
    // 遮盖
    private var coverView: UIView!
    // 当前单词书的掌握单词个数
    private var masteredWordsInCurrentBook: [Word] {
        if let user = user {
            if let words = user.learningBook?.wordList?.allObjects as? [Word] {
                return words.filter{$0.isMastered == true}
            }
        }
        return [Word]()
    }
    
    var cards: [Card] = []
    var words: [Word] = []
    var book: Book?
    var user: User? {
        didSet {
            if let rearViewController = revealViewController().rearViewController as? SidebarMenuTableViewController {
                rearViewController.user = self.user
            }
        }
    }
    
    // 懒加载用户需要学习的单词数组
    lazy var wordsNeedToLearn: [Word] = {
        if let user = user {
            return user.wordsNeedToLearn?.allObjects as! [Word]
        } else {
            return [Word]()
        }
    }()
    // 懒加载用户正在学习的单词数组
    lazy var learningWords: [Word] = {
        if let user = user {
            return user.learningWords?.allObjects as! [Word]
        } else {
            return [Word]()
        }
    }()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化cover view
        coverView = UIView(frame: self.view.frame)
        coverView.backgroundColor = .black
        coverView.alpha = 0
        
        // 目标控制器禁用手势
        if let navController = self.navigationController as? ITNavigationController {
            navController.addToForbiddenArray(for: ["WordListViewController", "CalendarViewController"])
        }
        
        // 如果用户不是第一次登陆，则从数据库中获取用户的数据
        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if loggedIn {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                let request: NSFetchRequest<User> = User.fetchRequest()
                let context = appDelegate.persistentContainer.viewContext
                let username = UserDefaults.standard.string(forKey: "username")
                request.predicate = NSPredicate(format: "username == %@", username!)
                request.fetchLimit = 1
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
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // 判断用户是否是第一次登陆
        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if !loggedIn {
            UserDefaults.standard.set(true, forKey: "loggedIn")
        }
        
        // 自定义导航栏颜色和字体
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 248.0/255.0, green: 148.0/255.0, blue: 6.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,.font: UIFont(name: "Avenir", size: 20.0)!]
        
        updateUI()
        
        // 判断是否需要加载单词数据
        if !dataIsFetched {
            fetchLearningData()
            dataIsFetched = true
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
            // 移除遮盖
            coverView.alpha = 0
            coverView.removeFromSuperview()
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        // pan手势开始时添加遮盖
        revealViewController().frontViewController.view.addSubview(coverView)
    }
    
    func revealController(_ revealController: SWRevealViewController!, panGestureMovedToLocation location: CGFloat, progress: CGFloat, overProgress: CGFloat) {
        // 根据滑动的距离改变cover view的透明度
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
    
    // MARK: - Outlets
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
    
    // MARK: - Present BookSelectionViewController
    @IBAction func switchLearningBook(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let bookSelectionViewController = storyBoard.instantiateViewController(withIdentifier: "BookSelectionViewController") as! BookSelectionViewController
        self.navigationController?.pushViewController(bookSelectionViewController, animated: true)
    }
    
    // MARK: - Unwind segues
    
    // Unwind segue from SummaryViewController
    @IBAction func takeABreak(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
        dataIsFetched = true
    }
    
    // Unwind segue from BookSelectionTableViewController
    @IBAction func showMainScreen(segue: UIStoryboardSegue) {
        let sourceController = segue.source as! BookSelectionViewController
        if let indexPath = sourceController.tableView.indexPathForSelectedRow {
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
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Prepare segues
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
    
    // MARK: - Methods
    func updateUI() {
        if let user = user {
            learnedWords = user.learnedWords?.count
            masteredWords = masteredWordsInCurrentBook.count
            totalWords = user.learningBook?.wordList?.count
        }
        daysCountLabel.text = String(user?.studyRecords?.count ?? 0)
        selectedBookLabel.text = user?.learningBook?.name
        learnedWordsLabel.text = String(learnedWords ?? 0)
        masteredWordsLabel.text = "\(masteredWords ?? 0) / \(totalWords ?? 3000)"
        mainScreenDashboardView.progress = Double(masteredWords ?? 0)/Double(totalWords ?? 1)
    }
    
    func createCardStack() {
        if learningWords.count < 50 && wordsNeedToLearn.count >= 10 {
            fetchLearningData(from: wordsNeedToLearn, count: 10)
        } else if learningWords.count >= 50 && wordsNeedToLearn.count >= 10 {
            let arr = [0, 25, 50, 75]
            let index = indexOfMaxValue(of: arr)
            let wordsOfMaxCount = wordsOfProgress(arr[index])
            fetchLearningData(from: wordsNeedToLearn, count: 3)
            if wordsOfMaxCount.count >= 7 && wordsOfProgress(0).count >= 5 {
                fetchLearningData(from: wordsOfMaxCount, count: 6)
                fetchLearningData(from: wordsOfProgress(0), count: 1)
            } else if wordsOfMaxCount.count >= 7 && wordsOfProgress(0).count < 5{
                fetchLearningData(from: wordsOfMaxCount , count: 7)
            } else {
                fetchLearningData(from: learningWords, count: 7)
            }
        } else {
            if wordsNeedToLearn.count > 0 {
                fetchLearningData(from: wordsNeedToLearn, count: wordsNeedToLearn.count)
                let count = (learningWords.count > 10 - wordsNeedToLearn.count) ? 10 - wordsNeedToLearn.count : learningWords.count
                fetchLearningData(from: learningWords, count: count)
            } else {
                if learningWords.count >= 10 {
                    fetchLearningData(from: learningWords, count: 10)
                } else {
                    fetchLearningData(from: learningWords, count: learningWords.count)
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
    
    private func wordsOfProgress(_ progress: Int) -> [Word] {
        return learningWords.filter{$0.progress == progress}
    }
    
    private func fetchLearningData(from wordList: [Word], count: Int) {
        var wordArray = [Word]()
        for word in wordList {
            wordArray.append(word)
            if wordArray.withoutDuplicates().count >= count {
                for word in wordArray {
                    fetchLearningData(for: word)
                }
                break
            }
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
                    self.user?.learningBook?.removeFromWordList(word)
                    self.user?.removeFromWordsNeedToLearn(word)
                    let nextWord = self.wordsNeedToLearn.last
                    if let nextWord = nextWord {
                        self.fetchLearningData(for: nextWord)
                    }

                    saveContext()
                }
                
                if let data = data {
                    let card = self.parseJsonData(data: data)
                    if let card = card, self.cards.count < 10 {
                        self.cards.append(card)
                        self.words.append(word)
                        print(self.cards.count)
                    }
                    
                }
                
                if self.cards.count >= 9 || self.cards.count == (self.wordsNeedToLearn.count + self.learningWords.count) {
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

// MARK: - Extensions for Array
public extension Array where Element: Equatable {
    @discardableResult
    // 打乱数组的顺序
    public mutating func shuffle() -> [Element] {
        guard count > 1 else {
            return self
        }
        
        for index in startIndex..<endIndex - 1 {
            let randomIndex = Int(arc4random_uniform(UInt32(endIndex - index))) + index
            if index != randomIndex {
                swapAt(index, randomIndex)
            }
        }
        return self
    }
    
    // 返回已经打乱顺序的数组
    public func shuffled() -> [Element] {
        var array = self
        return array.shuffle()
    }
    
    // 移除数组中重复的元素
    public mutating func removeDuplicates() {
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }
    
    // 返回已经去重的数组
    public func withoutDuplicates() -> [Element] {
        return reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }
}

// Public method: save user data
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


