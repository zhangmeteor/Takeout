//
//  TakeOutTests.swift
//  TakeOutTests
//
//  Created by xiaomeng on 12/12/22.
//

import XCTest
import RxSwift
@testable import TakeOut

final class TakeOutTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddFoodAffetCart() throws {
        let vm = TakeoutViewModel()
        
        let disposeBag = DisposeBag()
        let expect = expectation(description: "Food added exception")
        
        var lastView: AnimateView?
        vm.shoppingCart.subscribe(onNext: { carts in
            lastView = carts.last
            if lastView != nil {
                expect.fulfill()
            }
        }).disposed(by: disposeBag)
                               
        let newBuggerFood = BuggerView(food: Food(name: "BURGER2", price: 10))
        vm.foodAddPublish.accept(newBuggerFood)
        
        waitForExpectations(timeout: 10.0) {_ in
            XCTAssertEqual(lastView?.name, newBuggerFood.name)
        }
    }

    func testAddFoodTotalPrice() throws {
        let vm = TakeoutViewModel()
       
        let disposeBag = DisposeBag()
        let expect = expectation(description: "Food total price exception")
        
        var totalPrice: Int = 0
        
        vm.totalPrices.skip(3).subscribe(onNext: { price in
            totalPrice = price
            expect.fulfill()
        }).disposed(by: disposeBag)
                              
        // Added
        let newBuggerFood = BuggerView(food: Food(name: "BURGER", price: 4))
        vm.foodAddPublish.accept(newBuggerFood)
        let newFiresFood = BuggerView(food: Food(name: "Fries", price: 3))
        vm.foodAddPublish.accept(newFiresFood)
        let newLatteFood = BuggerView(food: Food(name: "Latte", price: 6))
        vm.foodAddPublish.accept(newLatteFood)
        
        
        waitForExpectations(timeout: 10.0) {_ in
            XCTAssertEqual(totalPrice, newBuggerFood.data.price + newFiresFood.data.price + newLatteFood.data.price)
        }
    }

//    func testAddFoodTotalPrice() throws {
//        let vc: TakeoutViewController = TakeoutViewController()
//        let _ = vc.view
//
//        let disposeBag = DisposeBag()
//        let expect = expectation(description: "Food total price exception")
//
//        var totalPrice: Int = 0
//    }

}
