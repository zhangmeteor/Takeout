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
    var foodViews: [AnimateView] = []
    
    lazy var latte: LatteView = LatteView(food: Food(name: "LATTE", price: 3))
    lazy var fries: FriesView = FriesView(food: Food(name: "FRIES", price: 4))
    lazy var burger: BuggerView = BuggerView(food: Food(name: "BURGER", price: 6))
    lazy var fries2: FriesView = FriesView(food: Food(name: "FRIES", price: 4))
    
    let menusViews: [UIImageView] = [UIImageView.init(image: UIImage(named: "menu_recommend")), UIImageView.init(image: UIImage(named: "menu_burger")), UIImageView.init(image: UIImage(named: "menu_drink")), UIImageView.init(image: UIImage(named: "menu_food"))]
    
    lazy var stars: StarsView = StarsView()
    
    /// shopping card added food view.
//    var shoppingCart: [AnimateView] = []
    var shoppingCart = BehaviorRelay<[AnimateView]>(value: [])
    lazy var foodAddEvent: Signal<AnimateView> = {
        return self.foodAddPublish.asSignal()
    }()
    let foodAddPublish: PublishRelay<AnimateView> = PublishRelay.init()

    /// card totoal prices
    var totalPrices = BehaviorSubject<Int>(value: 0)
    
    /// Location update
    let locationManager = LocationManager.init()
    
    override init() {
        super.init()
        
        foodViews = [fries, latte, burger, fries2]
        for (index, view) in foodViews.enumerated() {
            view.index = index
        }
        
        binding()
    }
    
    private func binding() {
        // add food in cart binding
        shoppingCart.subscribe(onNext: { [weak self] p in
            guard let self = self else {
                return
            }
            self.totalPrices.onNext(self.shoppingCart.value.reduce(0, { $0 + $1.data.price}))
        }).disposed(by: self.rx.disposeBag)
    }
}

extension TakeoutViewModel {
    struct Constant {
        static let smallViewCollideOffset: CGFloat = 20
    }
}
