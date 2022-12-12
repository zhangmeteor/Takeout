//
//  FoodView.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

protocol FoodView: UIView {
    /// index inside scrollview
    var index: Int? { get set }
    /// buy icon image
    var smallIcon: UIImageView { get set }
    /// icon image position on plates
    var position: PlatePosition { get set }
    /// data model for view
    var data: Food { get set }
    
    /// Animate name
    var name: String { set get }
    
    /// initial using Food
    init(food: Food)
    /// update Layout anytime when scrollView changed
    /// rate range from 0...1, show the scrolled rate.
    /// currentFood
    func updateLayout(_ rate: Double, direction: Direction, animate: AnimateType)
    
    /// hide Price UI
    func hidePrice()
    /// show Price UI
    func showPrice()
}

