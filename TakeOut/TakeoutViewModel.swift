//
//  ViewModel.swift
//  TakeOut
//
//  Created by xiaomeng on 12/7/22.
//

import Foundation
import UIKit
import RxSwift

class TakeoutViewModel {
    var foodViews: [AnimateView] = []
    
    lazy var latte: LatteView = LatteView(food: Food(name: "LATTE", price: 3))
    lazy var fries: FriesView = FriesView(food: Food(name: "FRIES", price: 4))
    lazy var burger: BuggerView = BuggerView(food: Food(name: "BURGER", price: 6))
    lazy var fries2: FriesView = FriesView(food: Food(name: "FRIES", price: 4))
    
    lazy var stars: StarsView = StarsView()
    
    var totalPrices = BehaviorSubject<Int>(value: 0)
    let locationManager = LocationManager.init()
    
    init() {
        foodViews = [fries, latte, burger, fries2]
        for (index, view) in foodViews.enumerated() {
            view.index = index
        }
    }
}

extension TakeoutViewModel {
    struct Constant {
        static let smallViewCollideOffset: CGFloat = 20
    }
}
