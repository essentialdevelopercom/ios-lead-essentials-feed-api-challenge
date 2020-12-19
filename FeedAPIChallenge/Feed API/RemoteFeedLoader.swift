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
		client.get(from: url, completion: {[weak self] result in
			guard let self = self else {return}
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(self.map(data, response))
			}
		})
	}
	
	func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		if response.statusCode == 200, let _ = try? JSONSerialization.jsonObject(with: data) {
			return .success([])
		} else {
			return .failure(Error.invalidData)
		}
	}
	
}
