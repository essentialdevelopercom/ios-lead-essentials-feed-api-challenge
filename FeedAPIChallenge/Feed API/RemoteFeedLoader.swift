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
		client.get(from: url) { [weak self] result in
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200,
				      let items = FeedImageMapper.decode(from: data) else {
					completion(.failure(Error.invalidData))
					return
				}

				if self != nil {
					completion(.success(items))
				}
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}
