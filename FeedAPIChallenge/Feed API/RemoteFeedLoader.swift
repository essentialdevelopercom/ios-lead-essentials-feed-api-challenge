//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private let OK_200 = 200

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [unowned self] result in
			switch result {
			case .success((_, let response)):
				guard response.statusCode == self.OK_200 else {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
					return
				}
			case .failure(_):
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
}
