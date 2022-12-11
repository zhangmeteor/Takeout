//
//  BaseAnimateView.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

// Base Animate for all food
class BaseAnimateView: UIView, AnimateView {
    var index: Int?
    var smallIcon: UIImageView = UIImageView()
    var position: PlatePosition = .middle
    var data: Food
    var name: String = "base"
    
    lazy var foodName: UILabel = {
        let lb = UILabel()
        lb.textColor = Constant.redColor
        lb.font = UIFont.systemFont(ofSize: 32)
        lb.alpha = 0
        
        return lb
    }()
    
    lazy var price: UILabel = {
        let p = UILabel()
        p.textColor = Constant.redColor
        p.font = UIFont.systemFont(ofSize: 24)
        p.alpha = 0
        
        return p
    }()
    
    required init(food: Food) {
        data = food
        name = food.name
        super.init(frame: .zero)

        initializeLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeLayout() {
        foodName.text = data.name
        price.text = "$\(data.price)"
        prepareDataUI()
    }
    
    fileprivate func prepareDataUI() {
        addSubview(foodName)
        foodName.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(Constant.Food.pricePadding)
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        addSubview(price)
        price.snp.makeConstraints { make in
            make.right.equalTo(foodName)
            make.top.equalTo(foodName.snp.bottom)
        }
    }
    
    func updateLayout(_ rate: Double, direction: Direction, animate: AnimateType) {
    }
    
    func hidePrice() {
        UIView.animate(withDuration: UIAnimationConfig.foodInfo.durtion) {
            self.foodName.transform = CGAffineTransformMakeTranslation(0, UIAnimationConfig.foodInfo.offset)
            self.price.transform = CGAffineTransformMakeTranslation(0, UIAnimationConfig.foodInfo.offset)
            
            self.foodName.alpha = 0
            self.price.alpha = 0
        }
    }
    
    func showPrice() {
        foodName.transform = CGAffineTransformMakeTranslation(0, -UIAnimationConfig.foodInfo.offset)
        price.transform = CGAffineTransformMakeTranslation(0, -UIAnimationConfig.foodInfo.offset)
        
        UIView.animate(withDuration: UIAnimationConfig.foodInfo.durtion) {
            self.foodName.alpha = 1
            self.price.alpha = 1
            
            self.foodName.transform = CGAffineTransformIdentity
            self.price.transform = CGAffineTransformIdentity
        }
    }
}

extension BaseAnimateView {
    struct Constant {
        static let redColor = UIColor(red: 235 / 255, green: 92 / 255, blue: 119 / 255, alpha: 1)
        
        struct Food {
            static let pricePadding = -37
        }
    }
}
