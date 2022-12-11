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

enum Direction {
    case left
    case right
}

enum Edge {
    case front
    case end
}

enum AnimateType {
    case animateIn
    case animateOut
}
