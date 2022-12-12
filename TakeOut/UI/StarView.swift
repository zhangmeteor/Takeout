//
//  StarView.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

final class StarsView: UIView {
    private lazy var smallStar: UIImageView = UIImageView(image: UIImage(named: "start_small"))
    private lazy var middleStar: UIImageView = UIImageView(image: UIImage(named: "start_middle"))
    private lazy var largeStar: UIImageView = UIImageView(image: UIImage(named: "start_large"))
    
    private var starPath: [StarType: [Path]] = [:]

    init() {
        super.init(frame: .zero)
        initializeLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateStarPath()
    }
    
    /// Stars animate
    /// each star move using the path defined.
    /// stars only rely on the origin food index (not the dynamic index by cache)
    public func updateLayout(_ rate: CGFloat, direction: Direction, originFoodIndex pathIdx: Int) {
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
            make.centerY.equalTo(smallStar).multipliedBy(Constant.middleStarCenterRatio)
        }
        
        addSubview(largeStar)
        largeStar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(Constant.largeStarCenterRatio)
        }
    }
}

/// Datas
fileprivate extension StarsView {
    /// star path for each star.
    func updateStarPath() {
        starPath = [.small: [
            Path(tx: self.frame.width * 0.5, ty: -self.frame.height * 0.25),
            Path(tx: -self.frame.width * 0.1, ty: 0.6 * self.frame.height),
            Path(tx: -self.frame.width * 0.4, ty: -self.frame.height * 0.35)
        ],
        .middle: [
            Path(tx: -self.frame.width * 0.55, ty: frame.height * 0.33),
            Path(tx: 10, ty: -0.45 * self.frame.height),
            Path(tx: self.frame.width * 0.55 - 10, ty: frame.height * 0.12)
        ],
        .large: [
            Path(tx: 0, ty: frame.height * 0.55),
            Path(tx: -frame.width * 0.43, ty: 0),
            Path(tx: frame.width * 0.43, ty: -frame.height * 0.55)
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
    
    struct Constant {
        static let middleStarCenterRatio = 0.8
        static let largeStarCenterRatio = 0.4
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
        
        return result
    }
}
