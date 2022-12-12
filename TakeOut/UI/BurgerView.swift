//
//  BurgerView.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

final class BuggerView: BaseFoodView {
    private lazy var burgerTop = UIImageView(image: UIImage(named: "burger_top"))
    private lazy var burgerBottom = UIImageView(image: UIImage(named: "burger_bottom"))
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(food: Food) {
        super.init(food: food)
        
        position = .left
        smallIcon = UIImageView(image: UIImage(named: "burger_small"))
    }
   
    /// Burger animate
    /// Move top burger away from bottom
    /// animateIn and animateOut make the opposite direction transaction.
    override func updateLayout(_ rate: Double, direction: Direction, animate: AnimateType) {
        if rate == 0 {
            return
        }
       
        var rate = rate
        switch animate {
        case .animateIn:
            rate = 1 - rate
        case .animateOut:
            break
        }
        
        burgerTop.transform = CGAffineTransformMakeTranslation(0, rate * UIAnimationConfig.burgerInfo.offset)
    }
    
    override func initializeLayout() {
        super.initializeLayout()
        
        addSubview(burgerBottom)
        burgerBottom.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-TopAnimate.bottomPadding)
            let ratio: CGFloat =  344 / 464
            make.height.equalTo(burgerBottom.snp.width).multipliedBy(ratio)
            make.width.equalToSuperview().multipliedBy(TopAnimate.foodWidthRate * Constant.bottomWidthRatio)
            make.left.equalToSuperview().offset(TopAnimate.leftPadding)
        }
        
        addSubview(burgerTop)
        burgerTop.snp.makeConstraints { make in
            let ratio: CGFloat = 266 / 373
            make.height.equalTo(burgerTop.snp.width).multipliedBy(ratio)
            make.width.equalToSuperview().multipliedBy(TopAnimate.foodWidthRate * Constant.topWidthRatio)
            make.bottom.equalTo(burgerBottom.snp.bottom).offset(Constant.bottomOffset)
            make.centerX.equalTo(burgerBottom)
        }
    }
    
    struct Constant {
        static let bottomWidthRatio = 1.1
        static let topWidthRatio = 0.9
        static let bottomOffset = -40 - UIAnimationConfig.burgerInfo.offset
    }
}
