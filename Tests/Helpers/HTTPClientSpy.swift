//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import Foundation
import FeedAPIChallenge

class HTTPClientSpy: HTTPClient {

	private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
	
	var requestedURLs: [URL] {
        self.messages.map { $0.url }
	}
	
	func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        self.messages.append((url, completion))
	}
	
	func complete(with error: Error, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        guard self.messages.count > index else {
            return XCTFail("Can't complete request never made", file: file, line: line)
        }

        self.messages[index].completion(.failure(error))
	}
	
	func complete(withStatusCode code: Int, data: Data, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        guard self.requestedURLs.count > index else {
            return XCTFail("Can't complete request never made", file: file, line: line)
        }
        
		let response = HTTPURLResponse(
            url: self.requestedURLs[index],
			statusCode: code,
			httpVersion: nil,
			headerFields: nil
		)!
        
        self.messages[index].completion(.success((data, response)))
	}

}
