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
    var vm = TakeoutViewModel()
 
    /// top menu bar ui
    private lazy var navigator: Navigator = {
        let nav = Navigator(menus: vm.menusViews)
        
        return nav
    }()
    /// bottom bar,  totoal price and pay ui
    private lazy var tabbar: Tabbar = Tabbar()
   
    /// sperate line between food and shoping cart view.
    private lazy var seprateLine: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = UIColor(red: 242 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1)
        
        return lb
    }()
    
    /// all content container, exclude the navgitor and tabbar
    private lazy var container: UIView = {
        let cView = UIView()
        cView.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)
        
        return cView
    }()
    
    /// Food showcase ui container using scrollview
    private lazy var scrollView: UIScrollView = {
        let scrView = UIScrollView()
    
        scrView.delegate = self
        scrView.isPagingEnabled = true
        scrView.contentSize = CGSize.init(width: CGFloat(vm.foodViews.count) * self.view.frame.size.width, height: scrView.frame.size.height)
        scrView.bounces = false
        scrView.showsHorizontalScrollIndicator = false
        
        return scrView
    }()
    
    /// scrollview views cache
    /// because to support loop,
    /// the sequece always changed, we need a cache to record current state.
    private lazy var cachedScrollView: [AnimateView] = []
    
    /// add food to shoping cart button.
    private lazy var addItem: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "add_item"), for: .normal)
        return btn
    }()

    /// Shoping cart animate ui container
    private lazy var shopingCartView: UIView = UIView()
  
    /// the shoping cart plates ui
    private lazy var plates = UIImageView(image: UIImage(named: "plates"))
    
    /// user location  information view inside shoping cart ui.
    private lazy var locationView = LocationView()

    /// the page index of visibale food in showcase.
    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareNavigator()
        prepareContainer()
        prepareShowcase()
        prepareSeperate()
        prepareShopingCartView()
        prepareMenu()

        UIBinding()
        updateInitialState()
    }
   
    /// Initial state when View showed.
    private func updateInitialState() {
        // try to retrive location at begining
        vm.locationManager.start()
        
        // scrollview should move last to front to support loop
        remakeScrollView(.front)
        
        // force show current food price automatic at begining
        let foodView = vm.foodViews[currentIndex]
        foodView.showPrice()
    }
    
    /// Using RxSwift for binding Data and UI
    private func UIBinding() {
        /// localtion changed to update label.
        vm.locationManager.currentLocaltion
            .asObservable()
            .bind(to: locationView.position.rx.text)
            .disposed(by: self.rx.disposeBag)
        
        /// shopcart foods total price affect the total price ui.
        vm.totalPrices
            .asObservable().subscribe(onNext: { [weak self] p in
                guard let self = self else {
                    return
                }
                self.tabbar.updatePrice(p)
            }).disposed(by: self.rx.disposeBag)
      
        // if shoping cart added new food,
        // refresh plates ui.
        vm.shoppingCart
            .subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
                let food = self.cachedScrollView[self.currentIndex]
                let iconView = food.smallIcon
                
                self.collideAlgorithm(food.position, icon: iconView)
        }).disposed(by: self.rx.disposeBag)
    }
    
    /// prepare content container
    private func prepareContainer() {
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(navigator.snp.bottom)
            make.bottom.equalTo(tabbar.snp.top)
            make.width.equalToSuperview()
        }
    }
    
    /// prepare showcase ui with animation
    private func prepareShowcase() {
        prepareScrollView()
        prepareShowcaseLayout(vm.foodViews, isInitialize: true)
        prepareOrnament()
        container.bringSubviewToFront(scrollView)
        prepareItemAdd()
    }
    
    /// prepare seperate line
    private func prepareSeperate() {
        view.addSubview(seprateLine)
        seprateLine.snp.makeConstraints { make in
            make.height.equalTo(3)
            make.top.equalTo(scrollView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    /// prepare shoping cart ui with animation
    private func prepareShopingCartView() {
        // Bottom View
        container.addSubview(shopingCartView)
        shopingCartView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalTo(seprateLine.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        // plates view
        shopingCartView.addSubview(plates)
        plates.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(Constant.platesCenterRatio)
            make.centerX.equalToSuperview()
            let ratio = 825 / 363
            make.width.equalTo(CGSize(width: ratio * Constant.platesHeight, height: Constant.platesHeight))
        }
        
        // location View
        container.addSubview(locationView)
        locationView.snp.makeConstraints { make in
            make.bottom.equalTo(tabbar.snp.top)
            make.height.equalTo(Constant.locationHeight)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    /// prepare menus on the top, inside navigator
    private func prepareMenu() {
        _ = vm.menusViews.map { menu in
            navigator.addSubview(menu)
        }
    }
   
    /// prepare shoping cart added button
    fileprivate func prepareItemAdd() {
        container.addSubview(addItem)
        
        addItem.snp.makeConstraints { make in
            make.size.equalTo(Constant.addItemSize)
            make.right.equalToSuperview().offset(Constant.addItemRightPadding)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        
        addItem.addTarget(self, action: #selector(addItemToBottom), for: .touchUpInside)
    }
    
    /// added food action
    /// first add ui to shoping cart
    /// send food added event, to notify model and ui update.
    @objc
    func addItemToBottom() {
        let food = cachedScrollView[currentIndex]
        let iconView = food.smallIcon
        guard iconView.superview != container else {
           return
        }
        
        addFoodInCartUI(food)
        vm.foodAddPublish.accept(food)
    }
    
    /// add food to cart ui.
    private func addFoodInCartUI(_ food: AnimateView) {
        let iconView = food.smallIcon
        
        self.container.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalTo(self.addItem)
            make.size.equalTo(Constant.iconSize)
        }
        
        iconView.transform = CGAffineTransformIdentity
        iconView.transform = CGAffineTransformMakeScale(0, 0)
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
    
    // Prepare show case ui layout, contains fries、latte、burger
    private func prepareShowcaseLayout(_ data: [AnimateView], isInitialize: Bool) {
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
    
    // like. stars animate
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
    /// this make scrollview loop happends
    /// if at end edge,
    /// move first element to last,
    ///
    /// if at front edge,
    /// move end element to firt,
    fileprivate func attachLoopView(_ position: Edge) {
        var index = 0
        switch position {
        case .front:
            index = cachedScrollView.count - 1
            
            let replaceView = cachedScrollView[index]
            cachedScrollView.remove(at: index)
            cachedScrollView.insert(replaceView, at: 0)
        case .end:
            index = 0
            
            let replaceView = cachedScrollView[index]
            cachedScrollView.remove(at: index)
            cachedScrollView.append(replaceView)
        }
    }
    
    /// remove all food view from superview
    fileprivate func removeAllFoodView() {
        _ = cachedScrollView.map { foodView in
            foodView.removeFromSuperview()
        }
    }
    
    /// remake Scrollview to support loop, called this method when reach the edge.
    /// 1. move view to edage.
    /// 2. remove all foodviews.
    /// 3. prepared layout.
    /// 4. update current page index and contentoffset
    fileprivate func remakeScrollView(_ position: Edge) {
        attachLoopView(position)
        removeAllFoodView()
        prepareShowcaseLayout(cachedScrollView, isInitialize: false)
        flushContentOffset(position)
    }
    
    fileprivate func flushContentOffset(_ position: Edge) {
        switch position {
        case .front:
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x + view.frame.width, y: scrollView.contentOffset.y)
        case .end:
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - view.frame.width, y: scrollView.contentOffset.y)
        }
        
        // fix current index
        currentIndex = Int(scrollView.contentOffset.x / view.frame.size.width)
    }
}

// MARK: ScrollView Delegate
extension TakeoutViewController: UIScrollViewDelegate {
    /// when scrollview ended, update current page index and show food price ui.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / view.frame.size.width)
        let foodView = cachedScrollView[currentIndex]
        
        UIView.animate(withDuration: UIAnimationConfig.addCartInfo.durtion) {
            self.addItem.alpha = 1
        }
        foodView.showPrice()
        
        if currentIndex == 0 {
            remakeScrollView(.front)
            currentIndex = Int(scrollView.contentOffset.x / view.frame.size.width)
        }
        
        if currentIndex >= cachedScrollView.count - 1 {
            remakeScrollView(.end)
            currentIndex = Int(scrollView.contentOffset.x / view.frame.size.width)
        }
    }
    
    /// when scrollview ended, hide food price ui.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let foodView = cachedScrollView[currentIndex]
        UIView.animate(withDuration: UIAnimationConfig.addCartInfo.durtion) {
            self.addItem.alpha = 0
        }
        
        foodView.hidePrice()
    }

    /// Scrolling action
    /// 1. found the food affect by this scroll action.
    /// 2. update affetted food animation layout with scroll direction.
    /// 3. update stars animation layout.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let foodIdx = Int(scrollView.contentOffset.x) / Int(view.frame.size.width)
        let currentFood = cachedScrollView[foodIdx]
        
        let x = scrollView.contentOffset.x
        
        // rate means moved rate compare the whole page moved.
        let rate =  1 - (self.view.frame.width * CGFloat(foodIdx + 1) - x) / self.view.frame.width

        // for current food, right means swap left
        // direction is the food moved direction.
        // find current and next food with direction
        let direction = x > CGFloat(foodIdx) * self.view.frame.width ? Direction.left : Direction.right
    
        var nextFood: AnimateView = currentFood
        
        switch direction {
        case .left:
            // if direction left, means moved to next page
            if foodIdx + 1 < cachedScrollView.count {
                nextFood = cachedScrollView[foodIdx + 1]
            }
        case .right:
            // if direction right, means moved to pre page
            if foodIdx - 1 > 0 {
                nextFood = cachedScrollView[foodIdx - 1]
            }
        }
       
        // Notify Layout updates
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
        
        // Star always need update
        // update starts layout path rely on food index in foodViews.
        if let originFoodIndex = vm.foodViews.firstIndex(where: { food in
            food.name == currentFood.name
        }) {
            vm.stars.updateLayout(rate, direction: direction, originFoodIndex: originFoodIndex)
        }
    }
}

// MARK: bottom animate algorithm
extension TakeoutViewController {
    /// collide algorithm for food added to cart together,
    private func collideAlgorithm(_ position: PlatePosition, icon: UIView) {
        let platesRect = self.shopingCartView.convert(self.plates.frame, to: self.container)
        
        // Refresh all layout anytime if food added.
        UIView.animate(withDuration: UIAnimationConfig.platesInfo.durtion) {
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
        let platesRect = self.shopingCartView.convert(self.plates.frame, to: self.container)
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
        let platesRect = self.shopingCartView.convert(self.plates.frame, to: self.container)
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
        let platesRect = self.shopingCartView.convert(self.plates.frame, to: self.container)
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

extension TakeoutViewController {
    struct Constant {
        static let iconSize = CGSize(width: 120, height: 120)
        static let platesHeight = 150
        static let platesCenterRatio = 0.8
        static let locationHeight = 80
        static let addItemSize = CGSize(width: 80, height: 80)
        static let addItemRightPadding = -15
    }
}
