//
//  FriesAnimateView.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

final class FriesView: BaseAnimateView {
    private lazy var friesBody = UIImageView(image: UIImage(named: "fries_body"))
    private lazy var friesLeft = UIImageView(image: UIImage(named: "fries_left"))
    private lazy var friesRight = UIImageView(image: UIImage(named: "fries_right"))
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(food: Food) {
        super.init(food: food)
        
        self.position = .right
        self.smallIcon = UIImageView(image: UIImage(named: "fires_small"))
        self.name = "Fires"
    }
    
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
        
        friesLeft.transform = CGAffineTransformMakeTranslation(0, rate * UIAnimationConfig.friesInfo.offset)
        friesRight.transform = CGAffineTransformMakeTranslation(0, rate * UIAnimationConfig.friesInfo.offset)
    }
    
    override func initializeLayout() {
        super.initializeLayout()
        
        addSubview(friesBody)
        friesBody.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-TopAnimate.bottomPadding)
            let ratio: Double = 474 / 395
            make.height.equalTo(friesBody.snp.width).multipliedBy(ratio)
            make.width.equalToSuperview().multipliedBy(TopAnimate.foodWidthRate)
            make.left.equalToSuperview().offset(TopAnimate.leftPadding)
        }
        
        addSubview(friesLeft)
        friesLeft.snp.makeConstraints { make in
            make.bottom.equalTo(friesBody.snp.top).offset(Constant.leftPading)
            let ratio: Double = 133 / 99
            make.width.equalTo(friesBody).multipliedBy(Constant.bodyWidthRatio)
            make.height.equalTo(friesLeft.snp.width).multipliedBy(ratio)
            make.left.equalTo(friesBody.snp.left).offset(-Constant.leftPading)
        }
        
        addSubview(friesRight)
        friesRight.snp.makeConstraints { make in
            make.bottom.equalTo(friesBody.snp.top).offset(Constant.rightPadding)
            let ratio: Double = 184 / 61
            make.width.equalTo(friesBody).multipliedBy(Constant.rightWidthRatio)
            make.height.equalTo(friesRight.snp.width).multipliedBy(ratio)
            make.centerX.equalTo(friesBody.snp.centerX).multipliedBy(Constant.rightCenterRatio)
        }
    }
}

extension FriesView {
    struct Constant {
        static let leftPading = 20
        static let rightPadding = 15
        
        static let bodyWidthRatio = 0.25
        static let rightWidthRatio = 0.15
        static let rightCenterRatio = 1.25
    }
}

