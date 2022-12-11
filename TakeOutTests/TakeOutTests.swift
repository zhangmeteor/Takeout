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

    func testAddFood() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let vc: TakeoutViewController = TakeoutViewController()
        let _ = vc.view
        
        let disposeBag = DisposeBag()
        let expect = expectation(description: "Food added exception")
        
        var lastView: AnimateView?
        vc.vm.shoppingCart.subscribe(onNext: { carts in
            lastView = carts.last
            if lastView != nil {
                expect.fulfill()
            }
        }).disposed(by: disposeBag)
                               
        let newBuggerFood = BuggerView(food: Food(name: "BURGER2", price: 10))
        vc.vm.foodAddPublish.accept(newBuggerFood)
        
        waitForExpectations(timeout: 10.0) {_ in
            XCTAssertEqual(lastView?.name, newBuggerFood.name)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
