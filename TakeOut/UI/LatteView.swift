//
//  LatteView.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

final class LatteView: BaseAnimateView {
    private lazy var cup = UIImageView(image: UIImage(named: "latte_cup"))
    private lazy var wave = UIImageView(image: UIImage(named: "latte_wave"))

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(food: Food) {
        super.init(food: food)
        
        position = .middle
        smallIcon = UIImageView(image: UIImage(named: "latte_small"))
    }
    
    override func updateLayout(_ rate: Double, direction: Direction, animate: AnimateType) {
        if rate == 0 {
            return
        }
        
        var rate = rate
        switch animate {
        case .animateIn:
            break
        case .animateOut:
            rate = 1 - rate
        }

        wave.transform = CGAffineTransform(scaleX: rate, y: rate)
    }
    
    override func initializeLayout() {
        super.initializeLayout()
        
        addSubview(cup)
        cup.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-TopAnimate.bottomPadding)
            let ratio: Double = 374 / 296
            make.height.equalTo(cup.snp.width).multipliedBy(ratio)
            make.width.equalToSuperview().multipliedBy(TopAnimate.foodWidthRate)
            make.left.equalToSuperview().offset(TopAnimate.leftPadding)
        }
        
        addSubview(wave)
        wave.snp.makeConstraints { make in
            make.bottom.equalTo(cup.snp.centerY)
            let ratio: Double = 290 / 312
            make.width.equalTo(cup).multipliedBy(Constant.waveWidthRatio)
            make.height.equalTo(wave.snp.width).multipliedBy(ratio)
            make.centerX.equalTo(cup.snp.centerX).multipliedBy(Constant.wavecenterRatio)
        }
        wave.layer.anchorPoint = CGPoint(x: 1, y: 1)
    }
}

extension LatteView {
    struct Constant {
        static let waveWidthRatio = 0.8
        static let wavecenterRatio = 1.15
    }
}
