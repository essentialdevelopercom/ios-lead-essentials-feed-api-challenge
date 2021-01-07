//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: URL(string: "https://a-given-url.com")!) { result in
			switch result {
			case .failure: completion(.failure(Error.connectivity))
			case let .success((data, response)):
				guard response.isValid() else {
					completion(.failure(Error.invalidData))
					return
				}
				if let _ = try? JSONSerialization.jsonObject(with: data) {
					completion(.success([]))
				} else {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}

private extension HTTPURLResponse {
	private static var StatusCodeSuccess = 200
	
	func isValid() -> Bool {
		return statusCode == HTTPURLResponse.StatusCodeSuccess
	}
}
