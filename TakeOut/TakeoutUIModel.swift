//
//  UIModel.swift
//  TakeOut
//
//  Created by xiaomeng on 12/10/22.
//

import Foundation
import UIKit


protocol AnimateView: UIView {
    /// index inside scrollview
    var index: Int? { get set }
    /// buy icon image
    var smallIcon: UIImageView { get set }
    /// icon image position on plates
    var position: PlatePosition { get set }
    /// data model for view
    var data: Food { get set }
    
    /// initial using Food
    init(food: Food)
    /// update Layout anytime when scrollView changed
    /// rate range from 0...1, show the scrolled rate.
    /// currentIdx: layout current Index
    func updateLayout(_ rate: Double, _ currentIdx: Int)
    
    /// hide Price UI
    func hidePrice()
    /// show Price UI
    func showPrice()
}

// Base Animate for all food
class BaseAnimateView: UIView, AnimateView {
    var index: Int?
    var smallIcon: UIImageView = UIImageView()
    var position: PlatePosition = .middle
    var data: Food
    
    var redColor = UIColor(red: 235 / 255, green: 92 / 255, blue: 119 / 255, alpha: 1)
    lazy var foodName: UILabel = {
        let lb = UILabel()
        lb.textColor = redColor
        lb.font = UIFont.systemFont(ofSize: 32)
        
        return lb
    }()
    
    lazy var price: UILabel = {
        let p = UILabel()
        p.textColor = redColor
        p.font = UIFont.systemFont(ofSize: 24)
        
        return p
    }()
    
    required init(food: Food) {
        data = food
        
        super.init(frame: .zero)
        initializeLayout()
        updateLayout(0, 0)
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
            make.right.equalToSuperview().offset(-37)
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        addSubview(price)
        price.snp.makeConstraints { make in
            make.right.equalTo(foodName)
            make.top.equalTo(foodName.snp.bottom)
        }
    }
    
    func updateLayout(_ rate: Double, _ currentIdx: Int) {
    }
    
    func hidePrice() {
        foodName.alpha = 0
        price.alpha = 0
    }
    
    func showPrice() {
        foodName.alpha = 1
        price.alpha = 1
    }
}

final class FriesView: BaseAnimateView {
    lazy var friesBody = UIImageView(image: UIImage(named: "fries_body"))
    lazy var friesLeft = UIImageView(image: UIImage(named: "fries_left"))
    lazy var friesRight = UIImageView(image: UIImage(named: "fries_right"))
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(food: Food) {
        super.init(food: food)
        
        self.position = .right
        self.smallIcon = UIImageView(image: UIImage(named: "fires_small"))
    }
    
    override func updateLayout(_ rate: Double, _ currentIdx: Int) {
        var rate = rate
        if let index = index, currentIdx != index - 1, index != 0 {
            rate = 1 - rate
        }
        
        friesLeft.transform = CGAffineTransformMakeTranslation(0, rate * 200)
        friesRight.transform = CGAffineTransformMakeTranslation(0, rate * 200)
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
            make.bottom.equalTo(friesBody.snp.top).offset(20)
            let ratio: Double = 133 / 99
            make.width.equalTo(friesBody).multipliedBy(0.25)
            make.height.equalTo(friesLeft.snp.width).multipliedBy(ratio)
            make.left.equalTo(friesBody.snp.left).offset(-20)
        }
        
        addSubview(friesRight)
        friesRight.snp.makeConstraints { make in
            make.bottom.equalTo(friesBody.snp.top).offset(15)
            let ratio: Double = 184 / 61
            make.width.equalTo(friesBody).multipliedBy(0.15)
            make.height.equalTo(friesRight.snp.width).multipliedBy(ratio)
            make.centerX.equalTo(friesBody.snp.centerX).multipliedBy(1.25)
        }
    }
}

final class LatteView: BaseAnimateView {
    lazy var cup = UIImageView(image: UIImage(named: "latte_cup"))
    lazy var wave = UIImageView(image: UIImage(named: "latte_wave"))

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(food: Food) {
        super.init(food: food)
        
        position = .middle
        smallIcon = UIImageView(image: UIImage(named: "latte_small"))

    }
    
    override func updateLayout(_ rate: Double, _ currentIdx: Int) {
        if rate == 0 {
            return
        }
        
        var rate = rate
        if let index = index, currentIdx != index - 1 {
            rate = 1 - rate
        }
        
        print("lattee rate: \(rate), idx: \(currentIdx)")
        wave.transform = CGAffineTransform(scaleX: rate, y: rate)
        print("\(wave.frame.width), \(wave.frame.height)")
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
            make.width.equalTo(cup).multipliedBy(0.8)
            make.height.equalTo(wave.snp.width).multipliedBy(ratio)
            make.centerX.equalTo(cup.snp.centerX).multipliedBy(1.15)
        }
        wave.layer.anchorPoint = CGPoint(x: 1, y: 1)
    }
}

final class BuggerView: BaseAnimateView {
    lazy var burgerTop = UIImageView(image: UIImage(named: "burger_top"))
    lazy var burgerBottom = UIImageView(image: UIImage(named: "burger_bottom"))
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(food: Food) {
        super.init(food: food)
        
        position = .left
        smallIcon = UIImageView(image: UIImage(named: "burger_small"))
    }
    
    override func updateLayout(_ rate: Double, _ currentIdx: Int) {
        if rate == 0 {
            burgerTop.transform = CGAffineTransformIdentity
            return
        }
    
        burgerTop.transform = CGAffineTransformMakeTranslation(0, (1 - rate) * Constant.expandHeight)
    }
    
    override func initializeLayout() {
        super.initializeLayout()
        
        addSubview(burgerBottom)
        burgerBottom.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-TopAnimate.bottomPadding)
            let ratio: CGFloat =  344 / 464
            make.height.equalTo(burgerBottom.snp.width).multipliedBy(ratio)
            make.width.equalToSuperview().multipliedBy(TopAnimate.foodWidthRate * 1.1)
            make.left.equalToSuperview().offset(TopAnimate.leftPadding)
        }
        
        addSubview(burgerTop)
        burgerTop.snp.makeConstraints { make in
            let ratio: CGFloat = 266 / 373
            make.height.equalTo(burgerTop.snp.width).multipliedBy(ratio)
            make.width.equalToSuperview().multipliedBy(TopAnimate.foodWidthRate * 0.9)
            make.bottom.equalTo(burgerBottom.snp.bottom).offset(-40 - Constant.expandHeight)
            make.centerX.equalTo(burgerBottom)
        }
        
        addSubview(foodName)
        foodName.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-47)
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        addSubview(price)
        price.snp.makeConstraints { make in
            make.right.equalTo(foodName)
            make.top.equalTo(foodName.snp.bottom)
        }
    }
    
    struct Constant {
        static let expandHeight: Double = 60
    }
}

final class StarsView: UIView {
    lazy var smallStar: UIImageView = UIImageView(image: UIImage(named: "start_small"))
    lazy var middleStar: UIImageView = UIImageView(image: UIImage(named: "start_middle"))
    lazy var largeStar: UIImageView = UIImageView(image: UIImage(named: "start_large"))
    
    private var starPath: [StarType: [Path]] = [:]
  
    init() {
        super.init(frame: .zero)
        initializeLayout()
        updateStarPath()
        updateLayout(0, 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateStarPath()
    }
    
    public func updateLayout(_ rate: CGFloat, _ pathIdx: Int) {
        print("rate: \(rate) - idx: \(pathIdx)")
        
        if rate == 0 {
            return
        }
        
        animateTranformPath(.small, rate: rate)
        animateTranformPath(.middle, rate: rate)
        animateTranformPath(.large, rate: rate)
        
        func animateTranformPath(_ type: StarType, rate: CGFloat) {
            guard let typePath = starPath[type], pathIdx < typePath.count else {
                return
            }
            
            // Get passed animated path result as key point.
            // all new anmiate for index should based on the key point.
            let olderPath = typePath.pathRef(pathIdx - 1)
            let currentPath = typePath[pathIdx]
            
            let tranform = CGAffineTransformMakeTranslation(olderPath.tx + currentPath.tx * rate, olderPath.ty + currentPath.ty * rate)
            
            switch type {
            case .small:
                smallStar.transform = tranform
            case .middle:
                middleStar.transform = tranform
            case .large:
                largeStar.transform = tranform
            }
        }
    }
    
    private func initializeLayout() {
        addSubview(smallStar)
        smallStar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(TopAnimate.leftPadding / 2)
            make.centerY.equalToSuperview().offset(TopAnimate.bottomPadding)
        }
        
        addSubview(middleStar)
        middleStar.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(TopAnimate.leftPadding)
            make.centerY.equalTo(smallStar).multipliedBy(0.8)
        }
        
        addSubview(largeStar)
        largeStar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.4)
        }
    }
}

/// Datas
fileprivate extension StarsView {
    func updateStarPath() {
        starPath = [.small: [
            Path(tx: self.frame.width * 0.5, ty: -self.frame.height * 0.25),
            Path(tx: -self.frame.width * 0.1, ty: 0.6 * self.frame.height)
        ],
        .middle: [
            Path(tx: -self.frame.width * 0.55, ty: frame.height * 0.33),
            Path(tx: 10, ty: -0.45 * self.frame.height)
        ],
        .large: [
            Path(tx: 0, ty: frame.height * 0.55),
            Path(tx: -frame.width * 0.43, ty: 0)
        ]
        ]
    }
}

fileprivate extension StarsView {
    struct Path {
        var tx: CGFloat
        var ty: CGFloat
        
        static func + (lhs: Path, rhs: Path) -> Path {
            return Path(tx: lhs.tx + rhs.tx, ty: lhs.ty + rhs.ty)
        }
    }
    
    enum StarType {
        case small
        case middle
        case large
    }
}

final class Navigator: UIView {
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class Tabbar: UIView {
    lazy var price: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 28)
        
        return lb
    }()
    
    lazy var pay: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Pay", for: .normal)
        btn.backgroundColor = UIColor(red: 255 / 255, green: 93 / 255, blue: 121 / 255, alpha: 1)
        
        return btn
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(price)
        price.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        addSubview(pay)
        pay.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(143)
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

final class LocationView: UIView {
    lazy var icon = UIImageView(image: UIImage(named: "map"))
    lazy var position: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.font = UIFont.systemFont(ofSize: 14)
        
        return lb
    }()
    
    lazy var dail = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "dail"), for: .normal)
        
        return btn
    }()
    
    init() {
        super.init(frame: .zero)
        
        position.text = "Test"
        
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        addSubview(dail)
        dail.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        addSubview(position)
        position.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(10)
            make.right.equalTo(dail.snp.left)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension Array where Element == StarsView.Path {
    /// Return transfer path related to origin position
    func pathRef(_ atIndex: Int) -> StarsView.Path {
        guard atIndex >= 0 else {
            return StarsView.Path(tx: 0, ty: 0)
        }
      
        let relatedPath = self.prefix(atIndex + 1)
        let result = relatedPath.reduce(StarsView.Path(tx: 0, ty: 0)) { result, path in
            return result + path
        }
        print("pathRef: \(atIndex), value: \(result)")
        
        return result
    }
}
