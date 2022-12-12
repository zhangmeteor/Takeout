//
//  Tabbar.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

final class Tabbar: UIView {
    private lazy var price: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 40)
        
        return lb
    }()
    
    private lazy var pay: GradientButton = {
        let btn = GradientButton([
            UIColor(red: 0.992, green: 0, blue: 0.237, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.363, blue: 0.473, alpha: 1).cgColor
                    ], locations: [0, 1])
        btn.setTitle("Pay", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        return btn
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(price)
        price.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constant.priceLeftPadding)
            make.centerY.equalToSuperview()
        }
        
        addSubview(pay)
        pay.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(Constant.payWidth)
            make.right.equalToSuperview()
        }
    }
    
    /// price using dollor unit.
    func updatePrice(_ amount: Int) {
        let unit = "$"
        let rawStr = "\(amount)" + unit
        let attribute = NSMutableAttributedString.init(string: rawStr)
        
        let range = (rawStr as NSString).range(of: unit)
        
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 35), range: range)
        UIView.animate(withDuration: UIAnimationConfig.priceInfo.durtion) {
            self.price.alpha = 0
        }
        
        UIView.animate(withDuration: UIAnimationConfig.priceInfo.durtion) {
            self.price.attributedText = attribute
            self.price.alpha = 1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Tabbar {
    struct Constant {
        static let priceLeftPadding = 20
        static let payWidth = 143
    }
}
