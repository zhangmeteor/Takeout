//
//  GradientButton.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit


final class GradientButton: UIButton {
    let gradient: CAGradientLayer = CAGradientLayer()
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(_ colors: [CGColor], locations: [NSNumber]?) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        applyGradient(colors,locations:locations)
    }
    
    func applyGradient(_ colors: [CGColor], locations: [NSNumber]?) {
        gradient.colors = colors
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
       
        layer.insertSublayer(gradient, at: 0)
    }
}
