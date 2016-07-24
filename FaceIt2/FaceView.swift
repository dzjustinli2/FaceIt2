//
//  FaceView.swift
//  FaceIt2
//
//  Created by justin on 24/07/2016.
//  Copyright © 2016 justin. All rights reserved.
//

import UIKit

class FaceView: UIView {
    
    var scale: CGFloat = 0.9
    var mouthCurvature: Double = -0.5
    var eyesOpen: Bool = false
    var eyeBrowTilt: Double = -1 //-1 full furrow, 1 full relax

    
    private var faceRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private var faceCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private struct Ratios {
        static let FaceRadiusToEyeOffset: CGFloat = 3
        static let FaceRadiusToEyeRadius: CGFloat = 10
        static let FaceRadiusToMouthWidth: CGFloat = 1
        static let FaceRadiusToMouthHeight: CGFloat = 3
        static let FaceRadiusToMouthOffset: CGFloat = 3
        static let FaceRadiusToBrowOffset: CGFloat = 5
    }
    
    private enum Eye {
        case Left
        case Right
    }
    
    private func pathForCircleCenteredAt(centerPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath{
        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        path.lineWidth = 5
        return path
    }
    
    private func pathForEye(eye: Eye) -> UIBezierPath {
        let eyeRadius = faceRadius / Ratios.FaceRadiusToEyeRadius
        let eyeCenter = getEyeCenter(eye)
        if eyesOpen {
            return pathForCircleCenteredAt(eyeCenter, withRadius: eyeRadius)
        } else {
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLineToPoint(CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
            path.lineWidth = 5
            return path
        }
    }
    
    private func getEyeCenter(eye: Eye) -> CGPoint{
        let eyeOffset = faceRadius / Ratios.FaceRadiusToEyeOffset
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeOffset
        
        switch eye {
        case .Left:
            eyeCenter.x -= eyeOffset
        case .Right:
            eyeCenter.x += eyeOffset
        }
        
        return eyeCenter
        
    }
    
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = faceRadius / Ratios.FaceRadiusToMouthWidth
        let mouthHeight = faceRadius / Ratios.FaceRadiusToMouthHeight
        let mouthOffset = faceRadius / Ratios.FaceRadiusToMouthOffset
        
        let mouthRectangle = CGRect(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthHeight, width: mouthWidth, height: mouthHeight)
        
        let smileIndex = CGFloat(max(min(mouthCurvature, 1), -1)) * mouthHeight
        
        let startOfMouth = CGPoint(x: mouthRectangle.minX, y: mouthRectangle.minY)
        let endOfMouth = CGPoint(x: mouthRectangle.maxX, y: mouthRectangle.minY)
        let controlPoint1 = CGPoint(x: mouthRectangle.minX + mouthWidth / 3, y: mouthRectangle.minY + smileIndex)
        let controlPoint2 = CGPoint(x: mouthRectangle.maxX - mouthWidth / 3, y: mouthRectangle.minY + smileIndex)
        
        let path = UIBezierPath()
        path.lineWidth = 5
        path.moveToPoint(startOfMouth)
        path.addCurveToPoint(endOfMouth, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        return path
    }
    
    private func pathForBrow(eye: Eye) -> UIBezierPath {
        var tilt = eyeBrowTilt
        
        let browOffset = faceRadius / Ratios.FaceRadiusToBrowOffset
        let eyeRadius = faceRadius / Ratios.FaceRadiusToEyeRadius

        switch eye {
        case .Left:
            tilt *= -1
        case .Right:
            break
        }
        
        let eyeBrowIndex = CGFloat(max(min(tilt, 1), -1)) * eyeRadius / 2
        
        let eyeCenter = getEyeCenter(eye)
        let browCenter = CGPoint(x: eyeCenter.x, y: eyeCenter.y - browOffset)
        
        let path = UIBezierPath()
        let browStart = CGPoint(x: browCenter.x - eyeRadius, y: browCenter.y - eyeBrowIndex)
        let browEnd = CGPoint(x: browCenter.x + eyeRadius, y: browCenter.y + eyeBrowIndex)
        path.moveToPoint(browStart)
        path.addLineToPoint(browEnd)
        path.lineWidth = 5
        
        return path
    }

    override func drawRect(rect: CGRect) {
        UIColor.orangeColor().setStroke()
        pathForCircleCenteredAt(faceCenter, withRadius: faceRadius).stroke()
        pathForEye(.Left).stroke()
        pathForEye(.Right).stroke()
        pathForMouth().stroke()
        pathForBrow(.Left).stroke()
        pathForBrow(.Right).stroke()
    }
    
}
