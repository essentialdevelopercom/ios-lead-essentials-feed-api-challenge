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

	private var OK_200: Int { return 200 }

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			switch result {
			case let .success((_, httpURLResponse)):

				if httpURLResponse.statusCode != self?.OK_200 {
					completion(.failure(Error.invalidData))
					return
				}

				completion(.success([]))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}
