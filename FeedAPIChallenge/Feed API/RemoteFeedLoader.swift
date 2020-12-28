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
		client.get(from: url) { result in
			switch result {
			case .success((let data, let response)):
				completion(RemoteFeedLoader.mapSuccessResult(data, response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	static func mapSuccessResult(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		if response.statusCode != 200 {
			return .failure(Error.invalidData)
		}
		let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
		if json == nil {
			return .failure(Error.invalidData)
		} else {
			return .success([])
		}
	}
	
}
