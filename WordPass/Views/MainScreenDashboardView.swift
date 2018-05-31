//
//  MainScreenDashboardView.swift
//  WordPass
//
//  Created by Apple on 07/04/2018.
//  Copyright © 2018 WordPass. All rights reserved.
//

import UIKit


@IBDesignable
class MainScreenDashboardView: UIView {
    
    //当前进度
    var progress: Double = 0.0 {
        didSet {
            if progress > 100.0 {
                progress = 100.0
            } else if progress < 0.0 {
                progress = 0.0
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        //绘制分割线
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 30.0, y: bounds.height/2 + 40.0))
        path.addLine(to: CGPoint(x: bounds.width - 30.0, y: bounds.height/2 + 40.0))
        UIColor.lightGray.setStroke()
        path.lineWidth = 1.0
        path.stroke()
        
        //绘制进度条外面的方框
        let rectPath = UIBezierPath()
        let upperleftPoint = CGPoint(x: 30.0, y: bounds.height*0.88)
        rectPath.move(to: upperleftPoint)
        rectPath.addLine(to: CGPoint(x: bounds.width - upperleftPoint.x, y: upperleftPoint.y))
        rectPath.addLine(to: CGPoint(x: bounds.width - upperleftPoint.x, y: upperleftPoint.y + 10.0))
        rectPath.addLine(to: CGPoint(x: upperleftPoint.x, y: upperleftPoint.y + 10.0))
        rectPath.close()
        #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1).setStroke()
        #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).setFill()
        rectPath.lineWidth = 3.0
        rectPath.stroke()
        rectPath.fill()
        
        //绘制进度条
        let progressBarPath = UIBezierPath()
        let barLength = (CGFloat(progress))*(bounds.width - 2*upperleftPoint.x - 4.0)
        let barWidth = CGFloat(8.0)
        progressBarPath.move(to: CGPoint(x: upperleftPoint.x + 2.0, y: upperleftPoint.y + 1.0))
        progressBarPath.addLine(to: CGPoint(x: upperleftPoint.x + 2.0 + barLength, y: upperleftPoint.y + 1.0))
        progressBarPath.addLine(to: CGPoint(x: upperleftPoint.x + 2.0 + barLength, y: upperleftPoint.y + 1.0 + barWidth))
        progressBarPath.addLine(to: CGPoint(x: upperleftPoint.x + 2.0, y: upperleftPoint.y + 1.0 + barWidth))
        progressBarPath.close()
        #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1).setFill()
        progressBarPath.fill()
        
    }
}
