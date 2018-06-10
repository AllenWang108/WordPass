//
//  ITNavigationController.swift
//  WordPass
//
//  Created by Apple on 2018/5/24.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit

// 实现全屏返回滑动效果
// 在每次push下一个视图之前截图保存到数组，滑动返回时取出数组的最后一个元素并位移到屏幕左端显示，滑动结束后pop掉当前视图并删除数组的最后一个元素
// IT stands for interactive transition
class ITNavigationController: UINavigationController {
    // MARK: - Properties
    
    // 屏幕高度及宽度
    private let screenWidth = UIScreen.main.bounds.size.width
    private let screenHeight = UIScreen.main.bounds.size.height
    // 滑动手势
    private var panGestureRec: UIPanGestureRecognizer!
    private var screenshotImageView: UIImageView!
    // 覆盖在截图上的view
    private var coverView: UIView!
    // 存放截图的数组
    private var screenshotImages = [UIImage]()
    // 存放要禁用滑动手势的controller类名的数组
    private var forbiddenArray = [String]()
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // 创建滑动手势，并默认禁用该手势
        panGestureRec = UIPanGestureRecognizer(target: self, action: #selector(performDragging(_:)))
        self.view.addGestureRecognizer(panGestureRec)
        panGestureRec.isEnabled = false
        
        // 创建显示截图的imageView
        screenshotImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        // 创建黑色半透明的view遮盖截图
        coverView = UIView(frame: (screenshotImageView.frame))
        coverView?.backgroundColor = .black
    }
    
    // MARK: - Action methods
    @objc private func performDragging(_ panGestureRec: UIPanGestureRecognizer) {
        // 如果当前视图是根控制器则直接返回
        if self.visibleViewController == self.viewControllers[0] {
            return
        }
        
        // 判断滑动手势的各个阶段
        switch panGestureRec.state {
        case .began:
            // 开始滑动
            dragWillBegin()
        case .ended:
            // 滑动结束
            dragDidEnd()
        default:
            // 滑动中
            dragging(with: panGestureRec)
        }
    }
    
    private func dragWillBegin() {
        // 每次开始滑动时，把截图的imageView和遮盖的coverView插到当前view的下面
        self.view.superview?.insertSubview(screenshotImageView, belowSubview: self.view)
        screenshotImageView.addSubview(coverView)
        
        
        // 显示截图数组中的最后一张截图
        if let image = screenshotImages.last {
            screenshotImageView.image = image
            screenshotImageView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    // coverView的默认透明度
    private let defaultAlpha: CGFloat = 0.4
    // coverView完全透明时，手指滑动的距离占屏幕宽度的比例
    private let targetTranslateScale: CGFloat = 0.75
    
    private func dragging(with panGesture: UIPanGestureRecognizer) {
        // 获取手指滑动的距离
        let offsetX = panGesture.translation(in: self.view).x
        // 如果是向右滑动（offsetX > 0）, 则将整个view平移相应的距离
        if offsetX > 0 {
            self.view.transform = CGAffineTransform(translationX: offsetX, y: 0)
        }
        // 当前滑动的距离占整个屏幕宽度的比例
        let currentTranslateScale = offsetX/self.view.frame.size.width
        if offsetX < screenWidth {
            // 先将截图向左平移（offsetX = -screenWidth*0.6），再向右平移
            screenshotImageView.transform = CGAffineTransform(translationX: (offsetX - screenWidth) * 0.6, y: 0)
        }
        // 当滑动的距离占了屏幕的总宽度的3/4时, coverView的alpha为0，完全透明
        coverView.alpha = defaultAlpha - (currentTranslateScale/targetTranslateScale) * defaultAlpha
    }
    
    private func dragDidEnd() {
        // 获取view平移的距离
        let translationX = self.view.transform.tx
        // 获取宽度
        let width = self.view.frame.size.width
        
        if translationX < screenWidth/2 {
            // 如果平移的距离小于屏幕宽度的一半，则将整个view向左侧弹回
            UIView.animate(withDuration: 0.25, animations: {
                // 清空transform，让view弹回到原位
                self.view.transform = .identity
                // 将截图向屏幕左侧位移直到其消失
                self.screenshotImageView.transform = CGAffineTransform(translationX: -self.screenWidth, y: 0)
                // 恢复默认的透明度
                self.coverView.alpha = self.defaultAlpha
            }) { (finished) in
                // 动画结束后将两个view移除
                self.screenshotImageView.removeFromSuperview()
                self.coverView.removeFromSuperview()
            }
        } else {
            // 如果平移的距离超过了屏幕的一半,往右边位移
            UIView.animate(withDuration: 0.25, animations: {
                // 将view移到屏幕的最右边直至消失
                self.view.transform = CGAffineTransform(translationX: width, y: 0)
                // 将imageView位移到原位
                self.screenshotImageView.transform = CGAffineTransform(translationX: 0, y: 0)
                // 让coverView完全透明
                self.coverView.alpha = 0
            }) { (finished) in
                // 清空view的transform
                self.view.transform = .identity
                self.screenshotImageView.removeFromSuperview()
                self.coverView.removeFromSuperview()
                // 移除栈顶控制器
                self.popViewControllerWithoutReturnValue(animated: false)
            }
        }
    }
    
    // 忽略pop的方法的返回值
    private func popViewControllerWithoutReturnValue(animated: Bool) {
        let _ = self.popViewController(animated: animated)
    }
    
    // 获取屏幕截图
    private func takeScreenshot() {
        let rootVC = UserDefaults.standard.bool(forKey: "rootVCSeted") ?self.view.window?.rootViewController : self.visibleViewController
        let size = rootVC?.view.frame.size
        
        if let size = size, let rootVC = rootVC {
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            let rect = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            rootVC.view.drawHierarchy(in: rect, afterScreenUpdates: true)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            if let screenshot = screenshot {
                self.screenshotImages.append(screenshot)
            }
            UIGraphicsEndImageContext()
        }
    }
    
    // MARK: - Override methods
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        var gestureEnabled = true
        // 判断目标控制器的滑动手势是否被禁用
        for str in forbiddenArray {
            let className = NSStringFromClass(type(of: viewController))
            if "WordPass.\(str)" == className {
                gestureEnabled = false
            }
        }
        self.panGestureRec.isEnabled = gestureEnabled
        
        // 如果导航里有自控制器则调用自定义方法截图
        if self.viewControllers.count >= 1 {
            takeScreenshot()
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let count = self.viewControllers.count
        var className = ""
        var gestureEnabled = true
        // 判断目标控制器的滑动手势是否被禁用
        if count >= 2 {
            className = NSStringFromClass(type(of: self.viewControllers[count - 2]))
        }
        for str in forbiddenArray {
            if "WordPass.\(str)" == className {
                gestureEnabled = false
            }
        }
        self.panGestureRec.isEnabled = gestureEnabled
        
        // pop时移除最后一张截图
        if !screenshotImages.isEmpty {
            screenshotImages.removeLast()
        }
        return super.popViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        // 删除多张截图
        for index in stride(from: self.viewControllers.count - 1, to: 0, by: -1) {
            if viewController == self.viewControllers[index] {
                break
            }
            screenshotImages.removeLast()
        }
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        // 删除全部截图
        screenshotImages.removeAll()
        return super.popToRootViewController(animated: animated)
    }
}

// MARK: - Extension
extension ITNavigationController {
    // 外部接口，传入控制器的类名禁用其滑动手势
    public func addToForbiddenArray(for classNames: [String]) {
        for str in classNames {
            self.forbiddenArray.append(str)
        }
    }
}
