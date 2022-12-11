//
//  LocationView.swift
//  TakeOut
//
//  Created by xiaomeng on 12/12/22.
//

import Foundation
import UIKit

final class LocationView: UIView {
    private lazy var icon = UIImageView(image: UIImage(named: "map"))
    private(set) lazy var position: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.font = UIFont.systemFont(ofSize: 14)
        
        return lb
    }()
    
    private lazy var dail = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "dail"), for: .normal)
        
        return btn
    }()
    
    init() {
        super.init(frame: .zero)
        
        position.text = ""
        
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constant.iconLeftOffset)
            make.centerY.equalToSuperview()
        }
        
        addSubview(dail)
        dail.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(Constant.dailRightOffset)
            make.centerY.equalToSuperview()
        }
        
        addSubview(position)
        position.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(Constant.positionLeftOffset)
            make.right.equalTo(dail.snp.left)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationView {
    struct Constant {
        static let positionLeftOffset = 10
        static let dailRightOffset = -20
        static let iconLeftOffset = 20
    }
}
