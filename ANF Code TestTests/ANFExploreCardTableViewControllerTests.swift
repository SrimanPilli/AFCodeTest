//
//  ANF_Code_TestTests.swift
//  ANF Code TestTests
//

import XCTest
@testable import ANF_Code_Test

final class ANFExploreCardTableViewControllerTests: XCTestCase {

    var sut: ANFExploreCardTableViewController!

    override func setUp() {
        super.setUp()
        sut = ANFExploreCardTableViewController()
        sut.loadViewIfNeeded()

        var mockCards: [ProductCard] = []
        for index in 0..<10 {
            let card = ProductCard(
                title: "Test Title \(index)",
                promoMessage: "Promo \(index)",
                backgroundImage: nil,
                topDescription: "Top \(index)",
                bottomDescription: "Bottom \(index)",
                content: nil,
                imageData: nil
            )
            mockCards.append(card)
        }
        sut.productCards = mockCards
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_numberOfSections_ShouldBeOne() {
        let numberOfSections = sut.numberOfSections(in: sut.tableView)
        XCTAssertEqual(numberOfSections, 1, "Table should have exactly one section")
    }

    func test_numberOfRows_ShouldBeTen() {
        let numberOfRows = sut.tableView(sut.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfRows, 10, "Should return 10 rows for mock data")
    }

    func test_cellForRowAtIndexPath_TitleText_ShouldNotBeBlank() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as? ExploreContentCell else {
            XCTFail("Expected ExploreContentCell")
            return
        }
        XCTAssertFalse(cell.titleLabel.text?.isEmpty ?? true, "Title label should not be empty")
    }

    func test_cellForRowAtIndexPath_ImageView_ShouldExist() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as? ExploreContentCell else {
            XCTFail("Expected ExploreContentCell")
            return
        }
        XCTAssertNotNil(cell.backgroundImageView, "Background image view should exist")
    }

    func test_OpenURL_ShouldOpenValidURL() {
        let validURLString = "https://www.apple.com"
        XCTAssertTrue(UIApplication.shared.canOpenURL(URL(string: validURLString)!), "Device should be able to open valid URL")
    }

    func test_CellConfiguration_SetsTopDescriptionAndPromo() {
        let card = sut.productCards.first!
        let cell = ExploreContentCell()
        cell.configure(with: card)

        XCTAssertEqual(cell.topDescriptionLabel.text, card.topDescription?.uppercased(), "Top description text should match")
        XCTAssertEqual(cell.promoMessageLabel.text, card.promoMessage, "Promo message should match")
    }

    func test_CellButtonCreation_ShouldCreateButtonsFromContent() {
        var card = sut.productCards.first!
        card = ProductCard(
            title: "Test",
            promoMessage: "Promo",
            backgroundImage: nil,
            topDescription: "Top",
            bottomDescription: "Bottom",
            content: [
                ContentButton(title: "Shop Now", target: "https://apple.com"),
                ContentButton(title: "Learn More", target: "https://developer.apple.com")
            ],
            imageData: nil
        )

        let cell = ExploreContentCell()
        cell.configure(with: card)

        XCTAssertEqual(cell.contentStackView.arrangedSubviews.count, 2, "Should create two buttons from content array")
    }
}

