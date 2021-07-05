//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol HTTPClient {
	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

	func get(from url: URL, completion: @escaping (Result) -> Void)
}

public class RemoteHTTPClient: HTTPClient {
	private let session: URLSession

	init(_ session: URLSession = .shared) {
		self.session = session
	}

	enum RemoteHTTPClientError: Error {
		case noDataNoResponseNoError
	}

	public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
		session.dataTask(with: url) { data, response, error in
			if let error = error {
				completion(.failure(error))
			} else if let data = data, let response = response as? HTTPURLResponse {
				completion(.success((data, response)))
			} else {
				completion(.failure(RemoteHTTPClientError.noDataNoResponseNoError))
			}
		}
	}
}
