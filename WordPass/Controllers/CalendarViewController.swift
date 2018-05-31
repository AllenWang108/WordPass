//
//  CalendarViewController.swift
//  WordPass
//
//  Created by Apple on 2018/5/16.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 当前选中的日期，初始值为当天的日期
    private var currentDate: Date = Date.init() {
        didSet {
            indexSet.removeAll()
            // 日期变更则重新加载视图
            monthLabel.text = "\(currentDate.year)年\(currentDate.month)月"
            collectionView.reloadData()
            // 根据collectionView的行数来决定其高度，7列6行一共有42个单元
            if collectionView.numberOfItems(inSection: 0) == 42 {
                collectionViewHeight.constant = collectionView.bounds.width*6/7
            } else {
                collectionViewHeight.constant = collectionView.bounds.width*5/7
            }
        }
    }
    var user: User!
    private lazy var studyRecords: [Record] = {
        return user.studyRecords?.allObjects as! [Record]
    }()
    
    private var studyDays: [Date] {
        let records = studyRecords.filter {$0.learnedWords?.count != nil}
        var days = [Date]()
        if !records.isEmpty {
            for record in records {
                days.append(record.startingTime!)
            }
        }
        return days
    }
    
    private var indexSet: [IndexPath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.8)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray,.font: UIFont(name: "Avenir", size: 18.0)!]

        collectionView.delegate = self
        collectionView.dataSource = self
        // 设置cell的大小
        let layout = UICollectionViewFlowLayout()
        let cellWidth: CGFloat = collectionView.bounds.width/7
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        // 关闭多选
        collectionView.allowsMultipleSelection = false
        
        // 根据collectionView的行数来决定其高度
        if collectionView.numberOfItems(inSection: 0) == 42 {
            collectionViewHeight.constant = collectionView.bounds.width*6/7
        } else {
            collectionViewHeight.constant = collectionView.bounds.width*5/7
        }
    }
    @IBOutlet var stackViews: [UIStackView]! {
        didSet {
            for view in stackViews {
                view.isHidden = true
            }
        }
    }
    @IBOutlet weak var studyTimeLabel: UILabel!
    @IBOutlet weak var learnedWordsCountLabel: UILabel!
    @IBOutlet weak var learnedDaysCountLabel: UILabel!
    @IBOutlet weak var noRecordView: UIView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var monthLabel: UILabel! {
        didSet {
            monthLabel.text = "\(currentDate.year)年\(currentDate.month)月"
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            // 添加手势
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
            leftSwipe.direction = .left
            collectionView.addGestureRecognizer(leftSwipe)
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
            rightSwipe.direction = .right
            collectionView.addGestureRecognizer(rightSwipe)
        }
    }
    
    // 左滑获取下个月的日期
    @objc func swipeLeft() {
        currentDate = currentDate.dateInNextMonth
        performAnimations(transition: kCATransitionFromRight)
    }
    
    // 右滑获取上个月的日期
    @objc func swipeRight() {
        currentDate = currentDate.dateInPreviousMonth
        performAnimations(transition: kCATransitionFromLeft)
    }
    
    // 动画过渡效果
    func performAnimations(transition: String) {
        let caTranstion = CATransition.init()
        caTranstion.duration = 0.5
        caTranstion.type = kCATransitionPush
        caTranstion.subtype = transition
        self.collectionView.layer.add(caTranstion, forKey: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    // 如果当前月份天数为30且第一天是星期六，或者天数为31且第一天是星期五或星期六，则一共显示六行，其余的情况显示五行
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (currentDate.totalDaysInMonth == 30 && currentDate.firstWeekdayInMonth >= 6) || (currentDate.totalDaysInMonth == 31 && currentDate.firstWeekdayInMonth >= 5) ? 42 : 35
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Date Cell", for: indexPath) as! CalendarCollectionViewCell
        // 默认将背景设置为白色，字体设置为灰色
        cell.roundedBackgroundView.backgroundColor = .white
        cell.dateLabel.textColor = .darkGray
        // 如果indexPath在日期范围之外则隐藏label，在范围之内则通过indexPath和当前月份第一天的index获取日期并显示
        if indexPath.row < self.currentDate.firstWeekdayInMonth || indexPath.row >= (self.currentDate.totalDaysInMonth + self.currentDate.firstWeekdayInMonth) {
            cell.dateLabel.isHidden = true
        } else {
            cell.dateLabel.text = String(indexPath.row - self.currentDate.firstWeekdayInMonth + 1)
            cell.dateLabel.isHidden = false
        }
        // 获取当天的日期
        let currentDate = Date.init()
        // 如果显示的月份年份和当天相同的话，标记当天的日期，并默认选择该日期，否则标记显示的月份的第一天
        // 标记学习过单词的日期，并记录其index
        if indexPath.row - currentDate.firstWeekdayInMonth + 1 == currentDate.day && currentDate.month == self.currentDate.month && currentDate.year == self.currentDate.year {
            cell.roundedBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            cell.dateLabel.textColor = UIColor.white
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        } else if indexPath.row == self.currentDate.firstWeekdayInMonth && (currentDate.month != self.currentDate.month || currentDate.year != self.currentDate.year) {
            cell.roundedBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            cell.dateLabel.textColor = UIColor.white
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        } else if canFindMatchedDays(with: self.currentDate, at: indexPath) {
            cell.roundedBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            cell.dateLabel.textColor = UIColor.white
            self.indexSet.append(indexPath)
        }
        
        return cell
    }
    
    // 判断能否在当前月份中找到用户背过单词的日期
    private func canFindMatchedDays(with date: Date, at indexPath: IndexPath) -> Bool {
        let currentDay = indexPath.row - date.firstWeekdayInMonth + 1
        return !studyDays.filter({$0.day == currentDay && $0.month == date.month && $0.year == date.year}).isEmpty
    }
    
    // 截止当前日期用户已经学习的天数
    private func getDayOrdinality(of date: Date, at indexPath: IndexPath) -> Int? {
        let currentDay = indexPath.row - date.firstWeekdayInMonth + 1
        return studyDays.sorted().index(where: {$0.day == currentDay && $0.month == date.month && $0.year == date.year})
    }
    
    // 获取当天学习的时长和单词数
    private func getStudyRecords(for date: Date, at indexPath: IndexPath) -> (duration: Int, count: Int) {
        let currentDay = indexPath.row - date.firstWeekdayInMonth + 1
        let record = studyRecords.filter({$0.startingTime?.day == currentDay && $0.startingTime?.month == date.month && $0.startingTime?.year == date.year}).first
        if let record = record {
            return (duration: Int(record.duration), count: record.learnedWords?.count ?? 1)
        } else {
            return (1,1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell
        // 标记选中的日期
        if indexPath.row >= currentDate.firstWeekdayInMonth && indexPath.row < (currentDate.totalDaysInMonth + currentDate.firstWeekdayInMonth) {
            selectedCell.roundedBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            selectedCell.dateLabel.textColor = UIColor.white
            //如果当天有学习记录则显示学习的时长和单词数
            if self.indexSet.contains(indexPath) {
                noRecordView.isHidden = true
                stackViews.forEach{$0.isHidden = false}
                learnedDaysCountLabel.text = String((getDayOrdinality(of: self.currentDate, at: indexPath) ?? 0) + 1)
                learnedWordsCountLabel.text = "\(getStudyRecords(for: self.currentDate, at: indexPath).count)"
                studyTimeLabel.text = "\(getStudyRecords(for: self.currentDate, at: indexPath).duration)"
            } else {
                noRecordView.isHidden = false
                stackViews.forEach{$0.isHidden = true}
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // 如果用户选择了其他日期则撤销标记
        let deselectedCell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell
        let currentDate = Date.init()
        if indexPath.row - currentDate.firstWeekdayInMonth + 1 == currentDate.day && currentDate.month == self.currentDate.month && currentDate.year == self.currentDate.year {
            deselectedCell.roundedBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 0.2915507277)
            deselectedCell.dateLabel.textColor = UIColor.darkGray
        } else if self.indexSet.contains(indexPath) {
            deselectedCell.roundedBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            deselectedCell.dateLabel.textColor = UIColor.white
        } else {
            deselectedCell.roundedBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            deselectedCell.dateLabel.textColor = UIColor.darkGray
        }
    }
}

extension Date {
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    //获取月份
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    //获取年份
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    // 获取上个月的日期
    var dateInPreviousMonth: Date {
        let calendar = Calendar.current
        var comp = calendar.dateComponents([.day, .month, .year], from: self)
        //定位到月中
        comp.setValue(15, for: .day)
        
        if comp.month == 1 {
            comp.month = 12
            comp.year! -= 1
        } else {
            comp.month! -= 1
        }
        
        return calendar.date(from: comp)!
    }
    
    // 获取下个月的日期
    var dateInNextMonth: Date {
        let calendar = Calendar.current
        var comp = calendar.dateComponents([.day, .month, .year], from: self)
        comp.setValue(15, for: .day)
        
        if comp.month == 12 {
            comp.month = 1
            comp.year! += 1
        } else {
            comp.month! += 1
        }
        
        return calendar.date(from: comp)!
    }
    
    // 当前月份的天数
    var totalDaysInMonth: Int {
        return Calendar.current.range(of: .day, in: .month, for: self)!.count
    }
    
    // 当前月份的第一天是星期几，返回0是星期天，返回1是星期一，以此类推
    var firstWeekdayInMonth: Int {
        let calendar = Calendar.current
        var comp = calendar.dateComponents([.day, .month, .year], from: self)
        comp.day = 1
        let firstDay = calendar.date(from: comp)
        let firstWeekday = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: firstDay!)! - 1
        return firstWeekday
    }
    
    static func == (lhs: Date, rhs: Date) -> Bool {
        return lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year
    }
}

