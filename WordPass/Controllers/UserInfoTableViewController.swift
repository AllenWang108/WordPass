//
//  UserInfoTableViewController.swift
//  WordPass
//
//  Created by Apple on 2018/5/28.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit
import CoreData

class UserInfoTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    // MARK: - Properties and outlets
    var user: User!
    private var pickerView: UIPickerView!
    private var datePickerView: UIDatePicker!
    private var tempContainerString: String!
    private var indexOfSelectedRow: Int?
    private var buttonContainerView: UIView!
    private var confirmButton: UIButton!
    private var cancelButton: UIButton!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2
            avatarImageView.layer.masksToBounds = true
            avatarImageView.image = UIImage(named: "avatar")
        }
    }
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var professionTextField: UITextField!
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.8)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray,.font: UIFont(name: "Avenir", size: 18.0)!]
        tableView.sectionHeaderHeight = 10
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        
        // 显示用户资料
        avatarImageView.image = user.avatar != nil ? UIImage(data: (user.avatar! as Data)) : UIImage(named: "avatar")
        nicknameTextField.text = user.nickname != nil ? user.nickname : ""
        genderLabel.text = user.gender ? "男" : "女"
        birthdayLabel.text = user.birthday != nil ? user.birthday : ""
        schoolTextField.text = user.school != nil ? user.school : ""
        professionTextField.text = user.profession != nil ? user.profession : ""
        nicknameTextField.delegate = self
        schoolTextField.delegate = self
        professionTextField.delegate = self
        
        // 初始化编辑和保存按钮
        editButton.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
        saveButton.target = self
        saveButton.action = #selector(saveUserInfo)
        
        // 初始化选择器和其它按钮
        pickerView = UIPickerView(frame: CGRect(x: 0, y: self.view.bounds.height - 200, width: self.view.bounds.width, height: 200))
        buttonContainerView = UIView(frame: CGRect(x: 0, y: pickerView.frame.origin.y - 30, width: self.view.bounds.width, height: 30))
        buttonContainerView.backgroundColor = #colorLiteral(red: 0.9220947623, green: 0.9263622165, blue: 0.9367930293, alpha: 1)
        cancelButton = UIButton(frame: CGRect(x: 10, y: buttonContainerView.frame.origin.y + 5, width: 50, height: 21))
        confirmButton = UIButton(frame: CGRect(x: pickerView.bounds.width - 60, y: buttonContainerView.frame.origin.y + 5, width: 50, height: 21))
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        confirmButton.setTitle("完成", for: .normal)
        confirmButton.setTitleColor(#colorLiteral(red: 0.9739639163, green: 0.7061158419, blue: 0.1748842001, alpha: 1), for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(.darkGray, for: .normal)
        pickerView.backgroundColor = #colorLiteral(red: 0.9220947623, green: 0.9263622165, blue: 0.9367930293, alpha: 1)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 初始化日期选择器
        datePickerView = UIDatePicker(frame: pickerView.frame)
        datePickerView.datePickerMode = .date
        datePickerView.locale = Locale(identifier: "zh_CN")
        datePickerView.backgroundColor = #colorLiteral(red: 0.9220947623, green: 0.9263622165, blue: 0.9367930293, alpha: 1)
        datePickerView.addTarget(self, action: #selector(getSelectedDate), for: .valueChanged)
    }
    
    // MARK: - Action methods
    // 提示用户选取照片
    @objc private func pickPhoto() {
        let photoSourceRequestController = UIAlertController(title: "", message: "选择照片来源", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "拍摄头像", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "从相册中选取", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        photoSourceRequestController.addAction(cancelAction)
        
        present(photoSourceRequestController, animated: true, completion: nil)
    }
    
    // 保存用户信息
    @objc private func saveUserInfo() {
        if let avatar = avatarImageView.image, avatar != UIImage(named: "avatar") {
            user.avatar = UIImagePNGRepresentation(avatar)
        }
        
        user.nickname = nicknameTextField.text == "" ? nil : nicknameTextField.text
        user.gender = genderLabel.text == "男" ? true : false
        user.birthday = birthdayLabel.text
        user.school = schoolTextField.text
        user.profession = professionTextField.text
        saveContext()
        
        let alertController = UIAlertController(title: "", message: "保存成功", preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
        let timer = Timer.init(timeInterval: 2, repeats: false, block: { (timer) in
            alertController.dismiss(animated: true, completion: {
                // 返回上一个界面
                self.dismiss(animated: true, completion: nil)
            })
        })
        timer.fire()
    }
    
    // 获取选中的日期
    @objc private func getSelectedDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "zh_CN")
        tempContainerString = dateFormatter.string(from: datePickerView.date)
    }
    
    // 确认按钮相应事件
    @objc private func confirm() {
        if indexOfSelectedRow == 1 {
            genderLabel.text = tempContainerString
        } else if indexOfSelectedRow == 2 {
            birthdayLabel.text = tempContainerString
        }
        removeAllSubviewsForSelectedRow(at: indexOfSelectedRow!)
    }
    
    // 取消按钮相应事件
    @objc private func cancel() {
        removeAllSubviewsForSelectedRow(at: indexOfSelectedRow!)
    }
    
    // 移除所有弹出来的视图
    private func removeAllSubviewsForSelectedRow(at index: Int) {
        buttonContainerView.removeFromSuperview()
        confirmButton.removeFromSuperview()
        cancelButton.removeFromSuperview()
        if index == 1 {
            pickerView.removeFromSuperview()
        } else if index == 2 {
            datePickerView.removeFromSuperview()
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    // 获取选中的照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatarImageView.image = selectedImage
            avatarImageView.contentMode = .scaleAspectFill
            avatarImageView.clipsToBounds = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "男" : "女"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tempContainerString = row == 0 ? "男" : "女"
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let index = indexOfSelectedRow {
            removeAllSubviewsForSelectedRow(at: index)
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = indexOfSelectedRow {
            removeAllSubviewsForSelectedRow(at: index)
        }
        indexOfSelectedRow = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 || indexPath.row == 2 {
            buttonContainerView.removeFromSuperview()
            self.tableView.superview?.addSubview(buttonContainerView)
            self.tableView.superview?.addSubview(confirmButton)
            self.tableView.superview?.addSubview(cancelButton)
            if indexPath.row == 1 {
                datePickerView.removeFromSuperview()
                self.tableView.superview?.addSubview(pickerView)
            } else {
                pickerView.removeFromSuperview()
                self.tableView.superview?.addSubview(datePickerView)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        switch section {
        case 0:
            headerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.9136785865, green: 0.9082472324, blue: 0.9178535342, alpha: 1)
        default:
            return
        }
    }
}
