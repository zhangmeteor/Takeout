//
//  TakeoutModel.swift
//  TakeOut
//
//  Created by xiaomeng on 12/11/22.
//

import Foundation

struct Food {
    var name: String
    var price: Int
}

struct UIConstant {
    static let navigatorHeight = 80
}

enum PlatePosition: Int {
    case middle
    case left
    case right
}

enum PlateDirection {
    case left
    case right
}

struct TopAnimate {
    static let leftPadding = 50
    static let bottomPadding = 20
    static let foodHeightRate: Double = 0.5
    static let foodWidthRate: Double = 0.4
}
