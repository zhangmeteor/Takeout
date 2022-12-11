//
//  UIModel.swift
//  TakeOut
//
//  Created by xiaomeng on 12/10/22.
//

import Foundation
import UIKit

struct AnimationInfo {
    var offset: CGFloat
    var durtion: CGFloat
}

class UIAnimationConfig {
    static let foodInfo: AnimationInfo = AnimationInfo(offset: 20, durtion: 0.3)
    static let friesInfo: AnimationInfo = AnimationInfo(offset: 80, durtion: 0)
    static let burgerInfo: AnimationInfo = AnimationInfo(offset: 60, durtion: 0)
    static let addCartInfo: AnimationInfo = AnimationInfo(offset: 0, durtion: 0.3)
    static let platesInfo: AnimationInfo = AnimationInfo(offset: 0, durtion: 0.5)
}

struct TopAnimate {
    static let leftPadding = 50
    static let bottomPadding = 20
    static let foodHeightRate: Double = 0.5
    static let foodWidthRate: Double = 0.4
}








