//
//  ABCircularProgressView.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

class ABCircularProgressView: UIView {

    /*
    *  ABCircularProgressView Config
    */

    /**
    * The width of the line used to draw the progress view.
    **/
    @objc let lineWidth: CGFloat = 1.0

    /**
    * The color of the progress view and the stop icon
    */
    @objc let tintCGColor: CGColor = UIColor.blue.cgColor

    /**
    * Size ratio of the stop button related to the progress view
    * @default 1/3 of the progress view
    */
    @objc let stopSizeRatio: CGFloat = 0.3

    /**
    * The Opacity of the progress background layer
    */
    @objc let progressBackgroundOpacity: Float = 0.1

    // define the chape layers
    fileprivate let progressBackgroundLayer = CAShapeLayer()
    fileprivate let circlePathLayer = CAShapeLayer()
    fileprivate let iconLayer = CAShapeLayer()

    @objc var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if newValue > 1 {
                circlePathLayer.strokeEnd = 1
            } else if newValue < 0 {
                circlePathLayer.strokeEnd = 0
                clearStopIcon()
            } else {
                circlePathLayer.strokeEnd = newValue
                drawStopIcon()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }

    fileprivate func setup() {
        progress = 0

        progressBackgroundLayer.frame = bounds
        progressBackgroundLayer.strokeColor = tintCGColor
        progressBackgroundLayer.fillColor = nil
        progressBackgroundLayer.lineCap = CAShapeLayerLineCap.round
        progressBackgroundLayer.lineWidth = lineWidth
        progressBackgroundLayer.opacity = progressBackgroundOpacity
        layer.addSublayer(progressBackgroundLayer)

        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = lineWidth
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = tintCGColor
        layer.addSublayer(circlePathLayer)

        iconLayer.frame = bounds
        iconLayer.lineWidth = lineWidth
        iconLayer.lineCap = CAShapeLayerLineCap.butt
        iconLayer.fillColor = nil
        layer.addSublayer(iconLayer)

        backgroundColor = UIColor.white
    }

    fileprivate  func circlePath() -> UIBezierPath {
        let circleRadius = (self.bounds.size.width - lineWidth)/2
        var cgRect = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        cgRect.origin.x = circlePathLayer.bounds.midX - cgRect.midX
        cgRect.origin.y = circlePathLayer.bounds.midY - cgRect.midY
        return UIBezierPath(ovalIn: cgRect)
    }

    fileprivate  func stopPath() -> UIBezierPath {
        let radius = bounds.size.width/2
        let sideSize = bounds.size.width * stopSizeRatio
        let stopPath: UIBezierPath = UIBezierPath()
        stopPath.move(to: CGPoint(x: 0, y: 0))
        stopPath.addLine(to: CGPoint(x: sideSize, y: 0.0))
        stopPath.addLine(to: CGPoint(x: sideSize, y: sideSize))
        stopPath.addLine(to: CGPoint(x: 0.0, y: sideSize))
        stopPath.close()
        stopPath.apply(CGAffineTransform(translationX: (radius * (1-stopSizeRatio)), y: (radius * (1-stopSizeRatio))))
        return stopPath
    }

    fileprivate  func drawStopIcon() {
        iconLayer.fillColor = tintCGColor
        iconLayer.path = stopPath().cgPath
    }

    fileprivate  func clearStopIcon() {
        iconLayer.fillColor = nil
        iconLayer.path = nil
    }

    fileprivate  func backgroundCirclePath() -> UIBezierPath {
        let startAngle: CGFloat = -(CGFloat)(M_PI / 2) // 90 degrees
        let endAngle: CGFloat = CGFloat(2 * M_PI) + startAngle
        let center: CGPoint = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        let radius: CGFloat = (bounds.size.width - lineWidth)/2

        // Draw background
        let processBackgroundPath: UIBezierPath = UIBezierPath()
        processBackgroundPath.lineWidth = lineWidth
        processBackgroundPath.lineCapStyle  = CGLineCap.round
        processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        return processBackgroundPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressBackgroundLayer.path = backgroundCirclePath().cgPath
        circlePathLayer.path = circlePath().cgPath

    }
}
