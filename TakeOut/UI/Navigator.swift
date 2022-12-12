//
//  Navigator.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

final class Navigator: UIView {
    private var stackView: UIStackView?
    
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
