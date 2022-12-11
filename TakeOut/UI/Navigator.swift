//
//  Navigator.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

final class Navigator: UIView {
    var stackView: UIStackView?
    
    init(menus: [UIImageView]) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        
        prepareStackView(menus)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    func prepareStackView(_ menus: [UIImageView]) {
        let widthRatio: Double = Double(1) / Double(menus.count)
        
        var lastMenu: UIImageView?
        for (index, menu) in menus.enumerated() {
            addSubview(menu)
            
            menu.contentMode = .scaleAspectFit
            
            defer {
                lastMenu = menu
            }
            
            guard let lastMenu = lastMenu else {
                menu.snp.makeConstraints { make in
                    make.left.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(widthRatio)
                }
                
                continue
            }
            
            guard index < menus.count - 1 else {
                menu.snp.makeConstraints { make in
                    make.left.equalTo(lastMenu.snp.right)
                    make.right.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(widthRatio)
                }
                continue
            }
            
            menu.snp.makeConstraints { make in
                make.left.equalTo(lastMenu.snp.right)
                make.centerY.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(widthRatio)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBackground()
    }
    
    private func updateBackground() {
        let layer0 = CAGradientLayer()
        layer0.colors = [
          UIColor(red: 0.992, green: 0, blue: 0.237, alpha: 1).cgColor,
          UIColor(red: 1, green: 0.363, blue: 0.473, alpha: 1).cgColor
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0, y: 0)
        layer0.endPoint = CGPoint(x: 1, y: 0)
        layer0.bounds = self.bounds.insetBy(dx: -0.5 * self.bounds.size.width, dy: -self.bounds.size.height / 2)
        self.layer.insertSublayer(layer0, at: 0)
    }
}

final class Tabbar: UIView {
    lazy var price: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 28)
        
        return lb
    }()
    
    lazy var pay: GradientButton = {
        let btn = GradientButton([
            UIColor(red: 0.992, green: 0, blue: 0.237, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.363, blue: 0.473, alpha: 1).cgColor
                    ], locations: [0, 1])
        btn.setTitle("Pay", for: .normal)
        
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
    
    func updatePrice(_ amount: Int) {
        price.text = "\(amount)$"
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