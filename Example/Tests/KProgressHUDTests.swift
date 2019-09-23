//
//  KProgressHUDTests.swift
//  KProgressHUD_Tests
//
//  Created by raniys on 9/20/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import KProgressHUD

class KProgressHUDTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        super.tearDown()
    }

    
    func testInitializers() {
        let rootView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        let hud = KProgressHUD.showAdded(to: rootView, animated: false)
        
        XCTAssertEqual(rootView.bounds, hud.frame)
        XCTAssertNotNil(hud.backgroundView.superview)
        XCTAssertNotNil(hud.bezelView.superview)
        XCTAssertEqual(hud.titleLabel.textColor, hud.contentColor)
        XCTAssertEqual(hud.detailsLabel.textColor, hud.contentColor)
        XCTAssertEqual(hud.actionButton.titleColor(for: .normal), hud.contentColor)
        
        XCTAssertEqual(hud.titleLabel.superview, hud.bezelView)
        XCTAssertEqual(hud.detailsLabel.superview, hud.bezelView)
        XCTAssertEqual(hud.actionButton.superview, hud.bezelView)
    }
}
