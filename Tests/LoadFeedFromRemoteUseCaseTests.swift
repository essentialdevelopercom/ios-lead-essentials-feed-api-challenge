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
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
	}
    
	func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "any-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversConnectivityErrorOnClientError() {
	}

	func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
	}

	func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
	}

	func test_load_deliversSuccessWithNoItemsOn200HTTPResponseWithEmptyJSONList() {
	}

	func test_load_deliversSuccessWithItemsOn200HTTPResponseWithJSONItems() {
	}

	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
	}
	
	// MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "any-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteFeedLoader(url: url, request: client.get)
        return (sut, client)
    }
    
    private class HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL) {
            requestedURLs.append(url)
        }
    }
}
