//
//  TakeoutModel.swift
//  TakeOut
//
//  Created by xiaomeng on 12/11/22.
//

import Foundation

struct Food: Equatable {
    var name: String
    var price: Int
    
    static func == (lhs: Food, rhs: Food) -> Bool {
        return lhs.name == rhs.name && lhs.price == rhs.price
    }
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
