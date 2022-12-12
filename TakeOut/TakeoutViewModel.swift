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
    /// supported foodViews container.
    private(set) var foodViews: [FoodView] = []
    
    /// supported food ui models
    private(set) lazy var latte: LatteView = LatteView(food: Food(name: "LATTE", price: 3))
    private(set) lazy var fries: FriesView = FriesView(food: Food(name: "FRIES", price: 4))
    private(set) lazy var burger: BuggerView = BuggerView(food: Food(name: "BURGER", price: 6))
    
    /// menus bar ui models.
    let menusViews: [UIImageView] = [UIImageView.init(image: UIImage(named: "menu_recommend")),
                                     UIImageView.init(image: UIImage(named: "menu_burger")), UIImageView.init(image: UIImage(named: "menu_drink")), UIImageView.init(image: UIImage(named: "menu_food"))]
    
    /// star Animation ui model
    private(set) lazy var stars: StarsView = StarsView()
    
    /// shopping card, each time when shoping cart changed, this behavior will trigger.
    private(set) var shoppingCart = BehaviorRelay<[FoodView]>(value: [])
    /// scrollview views cache
    /// because to support loop,
    /// the sequece always changed, we need a cache to record current state.
    lazy var cachedFoodList = BehaviorRelay<[FoodView]>(value: [])
    
    /// make food add pubulisher to event.
    private(set) lazy var foodAddEvent: Signal<FoodView> = {
        return self.foodAddPublish.asSignal()
    }()
    
    /// food added publisher, each time add food to cart, this will changed.
    let foodAddPublish: PublishRelay<FoodView> = PublishRelay.init()
    
    /// Scroll rate update
    private(set) var scrollContentOffset = BehaviorRelay<CGFloat>(value: 0)

    /// card totoal prices
    private(set) var totalPrices = BehaviorSubject<Int>(value: 0)
    
    /// Location update
    let locationManager = LocationManager.init()
    
    override init() {
        super.init()
        
        foodViews = [fries, latte, burger]
        for (index, food) in foodViews.enumerated() {
            food.index = index
        }
        
        binding()
    }
   
    /// Binding food changed.
    private func binding() {
        // add food in cart binding
        shoppingCart
            .map { $0.reduce(0, { $0 + $1.data.price }) }
            .bind(to: totalPrices)
            .disposed(by: rx.disposeBag)
        
        foodAddEvent.emit(onNext: { [weak self] food in
            guard let self = self else { return }
            // add food to shopping cart
            self.shoppingCart.accept(self.shoppingCart.value + [food])
        }).disposed(by: self.rx.disposeBag)
    }
}

extension TakeoutViewModel {
    struct Constant {
        static let smallViewCollideOffset: CGFloat = 20
    }
}
