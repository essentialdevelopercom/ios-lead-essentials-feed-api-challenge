//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedAPIChallenge

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
	
    //  ***********************
    //
    //  Follow the TDD process:
    //
    //  1. Uncomment and run one test at a time (run tests with CMD+U).
    //  2. Do the minimum to make the test pass and commit.
    //  3. Refactor if needed and commit again.
    //
    //  Repeat this process until all tests are passing.
    //
    //  ***********************
    
	func test_init_doesNotRequestDataFromURL() {
        let (_, client) = self.makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
    
	func test_loadTwice_requestsDataFromURLTwice() {
        let url = self.anyURL()
        let (sut, client) = self.makeSUT(url: url)

		sut.load { _ in }
		sut.load { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = self.makeSUT()

        self.expect(sut, toCompleteWith: .failure(.connectivity), when: {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		})
	}

	func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = self.makeSUT()

		let samples = [199, 201, 300, 400, 500]

		samples.enumerated().forEach { index, code in
            self.expect(sut, toCompleteWith: .failure(.invalidData), when: {
                let json = self.makeItemsJSON([])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}

	func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = self.makeSUT()

        self.expect(sut, toCompleteWith: .failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}

	func test_load_deliversSuccessWithNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = self.makeSUT()

        self.expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = self.makeItemsJSON([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		})
	}

	func test_load_deliversSuccessWithItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = self.makeSUT()

        let item1 = self.makeItem(
			id: UUID(),
			imageURL: URL(string: "http://a-url.com")!)

        let item2 = self.makeItem(
			id: UUID(),
			description: "a description",
			location: "a location",
			imageURL: URL(string: "http://another-url.com")!)

		let items = [item1.model, item2.model]

        self.expect(sut, toCompleteWith: .success(items), when: {
            let json = self.makeItemsJSON([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: json)
		})
	}

	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: self.anyURL(), client: client)

		var capturedResults = [RemoteFeedLoader.Result]()
		sut?.load { capturedResults.append($0) }

		sut = nil
        client.complete(withStatusCode: 200, data: self.makeItemsJSON([]))

		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	// MARK: - Helpers

    private func anyURL() -> URL { URL(string: "https://any-url.com")! }
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
        self.trackForMemoryLeaks(sut, file: file, line: line)
        self.trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}

	private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
		let item = FeedImage(id: id, description: description, location: location, url: imageURL)
		
		let json = [
			"image_id": id.uuidString,
			"image_desc": description,
			"image_loc": location,
			"image_url": imageURL.absoluteString
		].compactMapValues { $0 }
		
		return (item, json)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}

}
