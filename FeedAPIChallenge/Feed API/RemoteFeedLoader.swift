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
		client.get(from: url) { receivedResult in
			switch receivedResult {
			case let .success((receivedData, receivedResponse)):

				let result = FeedItemMapper.mapping(receivedData, from: receivedResponse)
				completion(result)

			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}
