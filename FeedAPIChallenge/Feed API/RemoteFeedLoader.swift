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
			if case let .success((data, response)) = result, response.statusCode == 200 {
				do {
					let _ = try JSONDecoder().decode(GetRemoteFeedImageResponseBody.self, from: data)
					completion(.success([]))
				} catch {
					print(error)
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				}
			} else if case .success = result {
				completion(.failure(RemoteFeedLoader.Error.invalidData))
			} else {
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
}
