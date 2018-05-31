//
//  AppDelegate.swift
//  WordPass
//
//  Created by Apple on 11/03/2018.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            preloadData()
            defaults.set(true, forKey: "isPreloaded")
        }
        
        // 状态栏改成白色
        // UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "WordPass")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
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

extension AppDelegate {
    func parseJson (contentsOfURL: URL, encoding: String.Encoding) -> [Word]?{
        var words: [Word]? = []
        var newContent: String
        let content = try? String(contentsOf: contentsOfURL, encoding: encoding)
        
        if let content = content {
            newContent = content.replacingOccurrences(of: "\t", with: "")
            newContent = newContent.replacingOccurrences(of: "\n", with: "")
            newContent = newContent.replacingOccurrences(of: "\r", with: "")
            newContent = newContent.replacingOccurrences(of: "\\", with: "")
            
            let decoder = JSONDecoder()
            if let jsonData = newContent.data(using: encoding) {
                do {
                    let wordlist = try decoder.decode([EnglishWord].self, from: jsonData)
                    let context = persistentContainer.viewContext
                    for eachWord in wordlist {
                        let word = Word(context: context)
                        word.englishWord = eachWord.word
                        word.definition = eachWord.def
                        words?.append(word)
                    }
                }
                catch {
                    print(error)
                }
            }
        }
        return words
    }
    
    func preloadData() {
        let bookNames = ["高考核心词汇","四级核心词汇","六级核心词汇","考研核心词汇","雅思核心词汇","托福核心词汇","SAT核心词汇","GRE核心词汇","专四核心词汇","专八核心词汇"]
        
        removeData()
        
        for bookName in bookNames {
            
            guard let contentsOfURL = Bundle.main.url(forResource: bookName, withExtension: "json") else {
                return
            }
            
            if let words = parseJson(contentsOfURL: contentsOfURL, encoding: String.Encoding.utf8) {
                let context = persistentContainer.viewContext
                let vocabularyBook = Book(context: context)
                vocabularyBook.name = bookName
                vocabularyBook.createdBy = "WordPass"
                for word in words{
                    vocabularyBook.addToWordList(word)
                }
                
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
            
        }
    }
    
    func removeData() {
        // Remove the existing items
        let fetchRequest = NSFetchRequest<Book>(entityName: "Book")
        let context = persistentContainer.viewContext
        
        do {
            
            let books = try context.fetch(fetchRequest)
            
            for book in books {
                context.delete(book)
            }
            
            saveContext()
            
        } catch {
            print(error)
        }
    }
}






