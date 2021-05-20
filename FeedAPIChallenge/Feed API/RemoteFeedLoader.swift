//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private let code_200 = 200

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

			guard let self = self else { return }

			switch result {
			case .success((_, let response)):

				if response.statusCode != self.code_200 {
					completion(.failure(Error.invalidData))
				}

			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}
