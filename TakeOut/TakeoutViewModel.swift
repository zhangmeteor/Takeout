//
//  ViewModel.swift
//  TakeOut
//
//  Created by xiaomeng on 12/7/22.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa

class TakeoutViewModel: NSObject {
    private(set) var foodViews: [AnimateView] = []
    
    private(set) lazy var latte: LatteView = LatteView(food: Food(name: "LATTE", price: 3))
    private(set) lazy var fries: FriesView = FriesView(food: Food(name: "FRIES", price: 4))
    private(set) lazy var burger: BuggerView = BuggerView(food: Food(name: "BURGER", price: 6))
    
    let menusViews: [UIImageView] = [UIImageView.init(image: UIImage(named: "menu_recommend")),
                                     UIImageView.init(image: UIImage(named: "menu_burger")), UIImageView.init(image: UIImage(named: "menu_drink")), UIImageView.init(image: UIImage(named: "menu_food"))]
    
    private(set) lazy var stars: StarsView = StarsView()
    
    /// shopping card added food view.
    private(set) var shoppingCart = BehaviorRelay<[AnimateView]>(value: [])
    
    private(set) lazy var foodAddEvent: Signal<AnimateView> = {
        return self.foodAddPublish.asSignal()
    }()
    
    let foodAddPublish: PublishRelay<AnimateView> = PublishRelay.init()

    /// card totoal prices
    private(set) var totalPrices = BehaviorSubject<Int>(value: 0)
    
    /// Location update
    let locationManager = LocationManager.init()
    
    override init() {
        super.init()
        
        foodViews = [fries, latte, burger]
        for (index, view) in foodViews.enumerated() {
            view.index = index
        }
        
        binding()
    }
    
    private func binding() {
        // add food in cart binding
        shoppingCart
            .map { $0.reduce(0, { $0 + $1.data.price }) }
            .bind(to: totalPrices)
            .disposed(by: rx.disposeBag)
    }
}

extension TakeoutViewModel {
    struct Constant {
        static let smallViewCollideOffset: CGFloat = 20
    }
}
