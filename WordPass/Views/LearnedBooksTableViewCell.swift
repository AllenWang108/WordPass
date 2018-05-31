//
//  LearnedBooksTableViewCell.swift
//  WordPass
//
//  Created by Apple on 2018/5/30.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class LearnedBooksTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    var user: User!
    private var books: [Book] {
        return user.learnedBooks?.allObjects as! [Book]
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            let layout = UICollectionViewFlowLayout()
            let cellWidth: CGFloat = (collectionView.bounds.width - 33)/3
            layout.itemSize = CGSize(width: cellWidth, height: collectionView.bounds.height)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumInteritemSpacing = 16.5
            layout.minimumLineSpacing = 16.5
            layout.scrollDirection = .horizontal
            collectionView.collectionViewLayout = layout
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.allowsSelection = false
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        collectionView.backgroundView?.isHidden = books.count > 0 ? true : false
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "learnedBookCell", for: indexPath) as! LearnedBookCollectionViewCell
        cell.bookNameLabel.text = books[indexPath.row].name
        cell.thumbnail.image = UIImage(named: books[indexPath.row].name!)
        cell.wordsCountLabel.text = "\(books[indexPath.row].wordList?.count ?? 0)词"
        
        return cell
    }
    
    
    
}
