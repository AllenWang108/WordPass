//
//  NewNoteTextViewController.swift
//  WordPass
//
//  Created by Apple on 2018/5/14.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

class NewNoteTextViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var noteTextView: UITextView!
    var word: Word!
    var noteContent: String?
    private var placeholderLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray,.font: UIFont(name: "Avenir", size: 18.0)!]
        let saveButton = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(saveNote))
        saveButton.setTitleTextAttributes([.foregroundColor: UIColor.darkGray,.font: UIFont(name: "Avenir", size: 18.0)!], for: .normal)
        self.navigationItem.setRightBarButton(saveButton, animated: true)
        noteTextView.delegate = self
        
        placeholderLabel = UILabel(frame: CGRect(x: 8, y: 8, width: noteTextView.bounds.width, height: 20))
        placeholderLabel.textAlignment = .left
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.font = UIFont.systemFont(ofSize: 17)
        placeholderLabel.text = "记录下对你有帮助的单词用法..."
        noteTextView.addSubview(placeholderLabel)
        if let noteContent = noteContent {
            noteTextView.text = noteContent
            placeholderLabel.text = ""
        }
    }
    
    // 保存笔记
    @objc private func saveNote() {
        if noteTextView.text.count == 0 {
            // 提示用户还没有输入文字
            let alertController = UIAlertController(title: "", message: "你还没有输入任何内容哦，是否放弃本次编辑", preferredStyle: .alert)
            let giveUpAction = UIAlertAction(title: "放弃", style: .destructive, handler: { alertAction in
                // 返回上一个界面
                self.navigationController?.popViewController(animated: true)
                })
            alertController.addAction(giveUpAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.preferredAction = giveUpAction
            present(alertController,animated: true, completion: nil)
        } else {
            word.note = noteTextView.text
            saveContext()
            // 提醒用户保存成功
            let alertController = UIAlertController(title: "", message: "保存成功", preferredStyle: .alert)
            present(alertController, animated: true, completion: nil)
            let timer = Timer.init(timeInterval: 2, repeats: false, block: { (timer) in
                alertController.dismiss(animated: true, completion: {
                    // 返回上一个界面
                    self.navigationController?.popViewController(animated: true)
                    })
                })
            timer.fire()
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        if noteTextView.text.count == 0 {
            placeholderLabel.text = "记录下对你有帮助的单词用法..."
        } else {
            placeholderLabel.text = ""
        }
    }

}
