//
//  ViewController.swift
//  TakeOut
//
//  Created by xiaomeng on 12/7/22.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TakeoutViewController: UIViewController {
    let vm = TakeoutViewModel()
 
//    lazy var lastContentOffset: (CGFloat, CGFloat) = (0, 0)
    lazy var navigator: Navigator = {
        let nav = Navigator(menus: vm.menusViews)
        
        return nav
    }()
    lazy var tabbar: Tabbar = Tabbar()
    
    /// all view container
    lazy var container: UIView = UIView()
    
    /// Top Animate UI using scrollview
    lazy var scrollView: UIScrollView = {
        let scrView = UIScrollView()
    
        scrView.delegate = self
        scrView.isPagingEnabled = true
        scrView.contentSize = CGSize.init(width: CGFloat(vm.foodViews.count) * self.view.frame.size.width, height: scrView.frame.size.height)
        scrView.bounces = false
        scrView.showsHorizontalScrollIndicator = false
        
        return scrView
    }()
    
    lazy var cachedScrollView: [AnimateView] = []
    
    /// add food to plates button.
    lazy var addItem: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "add_item"), for: .normal)
        return btn
    }()

    /// Bottom Animate UI Container
    lazy var bottomView: UIView = UIView()
  
    /// added food on plates
    lazy var plates = UIImageView(image: UIImage(named: "plates"))
    
    lazy var locationView = LocationView()

    
    /// Current food index.
    var currentIndex = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareNavigator()
        prepareContainer()
        prepareTopAnimation()
        prepareBottomAnimation()
        prepareMenu()

        UIBinding()
        
        // try to retrive location at begining
        vm.locationManager.start()
        
        // initialize show price automatic
        let foodView = vm.foodViews[currentIndex]
        foodView.showPrice()
    }
    
    /// Using RxSwift for binding Data and UI
    private func UIBinding() {
        vm.locationManager.currentLocaltion
            .asObservable()
            .bind(to: locationView.position.rx.text)
            .disposed(by: self.rx.disposeBag)
        
        vm.totalPrices
            .asObservable().subscribe(onNext: { [weak self] p in
                guard let self = self else {
                    return
                }
                
                self.tabbar.updatePrice(p)
            }).disposed(by: self.rx.disposeBag)
      
        /// add new food UI
        vm.foodAddEvent.emit(onNext: { [weak self] food in
            guard let self = self else { return }
            let iconView = food.smallIcon
            
            self.container.addSubview(iconView)
            iconView.snp.makeConstraints { make in
                make.center.equalTo(self.addItem)
                make.size.equalTo(CGSize(width: 120, height: 120))
            }
            
            iconView.transform = CGAffineTransformIdentity
            iconView.transform = CGAffineTransformMakeScale(0, 0)

            // add food to shopping cart
            self.vm.shoppingCart.accept(self.vm.shoppingCart.value + [food])
        }).disposed(by: self.rx.disposeBag)
                      
        // refresh plates UI
        vm.shoppingCart.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            let food = self.vm.foodViews[self.currentIndex]
            let iconView = food.smallIcon
            
            self.collideAlgorithm(food.position, icon: iconView)
        }).disposed(by: self.rx.disposeBag)
    }
    
    /// prepare base container
    private func prepareContainer() {
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(navigator.snp.bottom)
            make.bottom.equalTo(tabbar.snp.top)
            make.width.equalToSuperview()
        }
    }
    
    /// prepare top UI with animation
    private func prepareTopAnimation() {
        prepareScrollView()
        prepareFoodLayout(vm.foodViews, isInitialize: true)
        prepareOrnament()
        container.bringSubviewToFront(scrollView)
        prepareItemAdd()
    }
    
    /// prepare bottom UI with animation
    private func prepareBottomAnimation() {
        // Bottom View
        container.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalTo(scrollView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        // Plates
        bottomView.addSubview(plates)
        plates.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
            let ratio = 825 / 363
            make.width.equalTo(CGSize(width: ratio * 150, height: 150))
        }
        
        // location View
        container.addSubview(locationView)
        locationView.snp.makeConstraints { make in
            make.bottom.equalTo(tabbar.snp.top)
            make.height.equalTo(80)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    /// Prepare Menus
    private func prepareMenu() {
        _ = vm.menusViews.map { menu in
            navigator.addSubview(menu)
        }
    }
   
    /// Add food to cart
    fileprivate func prepareItemAdd() {
        container.addSubview(addItem)
        
        addItem.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        
        addItem.addTarget(self, action: #selector(addItemToBottom), for: .touchUpInside)
    }
    
    @objc
    func addItemToBottom() {
        let food = vm.foodViews[currentIndex]
        let iconView = food.smallIcon
        guard iconView.superview != container else {
           return
        }

        vm.foodAddPublish.accept(food)
    }
    
    private func prepareScrollView() {
        container.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview()
        }
    }
    
    private func prepareNavigator() {
        view.addSubview(navigator)
        navigator.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
            make.height.equalTo(UIConstant.navigatorHeight)
        }
        
        view.addSubview(tabbar)
        tabbar.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
            make.height.equalTo(UIConstant.navigatorHeight)
        }
    }
    
    // Prepare UI layout, contains fries、latte、burger
    private func prepareFoodLayout(_ data: [AnimateView], isInitialize: Bool) {
        var lastView: UIView?
        
        _ = data.map { foodView in
            scrollView.addSubview(foodView)
            foodView.snp.makeConstraints { make in
                make.size.equalToSuperview()
                
                guard let lastView = lastView else {
                    make.left.equalToSuperview()
                    return
                }
                
                make.left.equalTo(lastView.snp.right)
            }
            
            lastView = foodView
            
            if isInitialize == true {
                self.cachedScrollView.append(foodView)
            }
        }
    }
    
    // like. stars
    // the initialize postion should rely on fries(first food)
    // warning: must called after prepareFoodLayout.
    private func prepareOrnament() {
        container.addSubview(vm.stars)
        vm.stars.snp.makeConstraints { make in
            make.size.equalTo(scrollView)
            make.center.equalTo(scrollView)
        }
    }
}

// MARK: Loop scrollview
extension TakeoutViewController {
    /// move first element to last, this make loop happends
    fileprivate func attachLoopView() {
        guard let firstView = cachedScrollView.first else {
            return
        }
        
        cachedScrollView.remove(at: 0)
        cachedScrollView.append(firstView)
    }
    
    ///  remove all food view from superview
    fileprivate func removeAllFoodView() {
        _ = cachedScrollView.map { foodView in
            foodView.removeFromSuperview()
        }
    }
    
    /// remake Scrollview to support loop, called this method when reach the edge.
    fileprivate func remakeScrollView() {
        attachLoopView()
        removeAllFoodView()
        prepareFoodLayout(cachedScrollView, isInitialize: false)
        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - view.frame.width, y: scrollView.contentOffset.y)
    }
}

// MARK: ScrollView Delegate
extension TakeoutViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / view.frame.size.width)
        let foodView = cachedScrollView[currentIndex]
        
        UIView.animate(withDuration: 0.3) {
            self.addItem.alpha = 1
        }
        foodView.showPrice()
        
        if currentIndex == cachedScrollView.count - 1 {
            remakeScrollView()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let foodView = cachedScrollView[currentIndex]
        UIView.animate(withDuration: 0.3) {
            self.addItem.alpha = 0
        }
        
        foodView.hidePrice()
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.x < lastContentOffset.0 {
//            return
//        }
        let foodIdx = Int(scrollView.contentOffset.x) / Int(view.frame.size.width)
        let currentFood = cachedScrollView[foodIdx]
        
        let x = scrollView.contentOffset.x
        
        // rate means moved rate compare the whole page moved.
        let rate =  1 - (self.view.frame.width * CGFloat(foodIdx + 1) - x) / self.view.frame.width

        // for current food, right means swap left
        // direction is the food moved direction.
        var direction = x > CGFloat(currentIndex) * self.view.frame.width ? Direction.left : Direction.right
    
        var nextFood: AnimateView = currentFood
        
        switch direction {
        case .left:
            // if direction left, means moved to next page
            if currentIndex + 1 < cachedScrollView.count {
                nextFood = cachedScrollView[currentIndex + 1]
            }
        case .right:
            // if direction right, means moved to pre page
            if currentIndex - 1 > 0 {
                nextFood = cachedScrollView[currentIndex - 1]
            }
        }
        
        _ = cachedScrollView.map { food in
            // only current food and next food need animated update.
            if currentFood == food {
                food.updateLayout(rate, direction: direction, animate: .animateOut)
                return
            }
            
            if nextFood == food {
                food.updateLayout(rate, direction: direction, animate: .animateIn)
                return
            }
        }
        
        
//
//        // currentIdx is first
//        if x < self.view.frame.width {
//            let rate = x / self.view.frame.width
//
//            _ = cachedScrollView.map { food in
//                if currentFood == food {
//                    x >
//                    food.updateLayout(rate, 0)
//                }
//                food.updateLayout(rate, 0)
//            }
//            vm.stars.updateLayout(rate, 0)
//        }
//
//        if self.view.frame.width...self.view.frame.width * 2 ~= x {
//            let rate = 1 - (self.view.frame.width * 2 - x) / self.view.frame.width
//
//            _ = vm.foodViews.map { view in
//                view.updateLayout(rate, 1)
//            }
//            vm.stars.updateLayout(rate, 1)
//        }
//
//        if self.view.frame.width * 2...self.view.frame.width * 3 ~= x {
//            let rate = (self.view.frame.width * 3 - x) / self.view.frame.width
//            _ = vm.foodViews.map { view in
//                view.updateLayout(rate, 2)
//            }
//
//            vm.stars.updateLayout(rate, 2)
//        }
    }
}

// MARK: bottom animate algorithm
extension TakeoutViewController {
    private func collideAlgorithm(_ position: PlatePosition, icon: UIView) {
        let platesRect = self.bottomView.convert(self.plates.frame, to: self.container)
        
        // Refresh all layout anytime if food added.
        UIView.animate(withDuration: 0.5) {
            self.leftPositionFlush(platesRect)
            self.rightPositionFlush(platesRect)
            self.middlePositionFlush(platesRect)
        }
    }
    
    /// left foot added
    /// if right food contains, move left to avoid collide
    private func leftPositionFlush(_ platesRect: CGRect) {
        guard let leftView = vm.shoppingCart.value.first(where: { $0.position == .left }) else {
            return
        }
        let platesRect = self.bottomView.convert(self.plates.frame, to: self.container)
        var tx = platesRect.origin.x + platesRect.size.width * 0.4 - self.addItem.frame.midX
        let ty = platesRect.origin.y + 0.5 * platesRect.size.height - self.addItem.frame.midY

        if vm.shoppingCart.value.first(where: { $0.position == .right }) != nil {
            tx = tx - TakeoutViewModel.Constant.smallViewCollideOffset
        }

        leftView.smallIcon.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(tx, ty), CGAffineTransformMakeScale(1, 1))
    }
    
    /// right foot added
    private func rightPositionFlush(_ platesRect: CGRect) {
        guard let rightView = vm.shoppingCart.value.first(where: { $0.position == .right }) else {
            return
        }
        let platesRect = self.bottomView.convert(self.plates.frame, to: self.container)
        let tx = platesRect.origin.x + platesRect.size.width * 0.66 - self.addItem.frame.midX
        let ty = platesRect.origin.y + 0.33 * platesRect.size.height - self.addItem.frame.midY
        
        rightView.smallIcon.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(tx, ty), CGAffineTransformMakeScale(1, 1))
    }
    
    /// middle foot added
    /// if right food contains, move left to avoid collide
    /// if left food contains, move right to avoid collide
    private func middlePositionFlush(_ platesRect: CGRect) {
        guard let middleView = vm.shoppingCart.value.first(where: { $0.position == .middle }) else {
            return
        }
        let platesRect = self.bottomView.convert(self.plates.frame, to: self.container)
        var tx = platesRect.origin.x + platesRect.width * 0.48 - self.addItem.frame.midX
        let ty = platesRect.origin.y - self.addItem.frame.size.height / 2 - self.addItem.frame.origin.y
        
        if vm.shoppingCart.value.first(where: { $0.position == .right }) != nil {
            tx = tx - TakeoutViewModel.Constant.smallViewCollideOffset
        }
        
        if vm.shoppingCart.value.first(where: { $0.position == .left }) != nil {
            tx = tx + TakeoutViewModel.Constant.smallViewCollideOffset
        }
        
        middleView.smallIcon.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(tx, ty), CGAffineTransformMakeScale(1, 1))
    }
}
