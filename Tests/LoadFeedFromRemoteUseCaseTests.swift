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
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: makeJSONItems([]), at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidData = Data("invalid data".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        })
    }
    
    func test_load_deliversSuccessWithNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJSONList = makeJSONItems([])
            client.complete(withStatusCode: 200, data: emptyJSONList)
        })
    }
    
    func test_load_deliversSuccessWithItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(description: "a description",
                              location: "a location",
                              imageURL: URL(string: "any-image-url.com")!
        )
        
        let item2 = makeItem(description: nil,
                              location: nil,
                              imageURL: URL(string: "any-image-url.com")!
        )
        
        let items = [item1, item2]
        
        expect(sut, toCompleteWith: .success(items.map { $0.model }), when: {
            client.complete(withStatusCode: 200, data: makeJSONItems(items.map { $0.json }))
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClient()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: URL(string: "any-url.com")!, request: client.get)
        
        var receivedResults: [RemoteFeedLoader.Result] = []
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeJSONItems([]))
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "any-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteFeedLoader(url: url, request: client.get)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(expectedError as RemoteFeedLoader.Error), .failure(receivedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            default:
                XCTFail("Expected failure, got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: UUID(),
                             description: description,
                             location: location,
                             url: imageURL
        )
        let itemJSON = [
            "image_id": item.id.uuidString,
            "image_desc": item.description,
            "image_loc": item.location,
            "image_url": item.url.absoluteString
            ].compactMapValues { $0 }
        
        return (item, itemJSON)
    }
    
    private func makeJSONItems(_ items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": items])
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private class HTTPClient {
        typealias Result = (Swift.Result<(Data, HTTPURLResponse), Swift.Error>) -> Void
        private var messages = [(url: URL, completion: Result)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping Result) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
