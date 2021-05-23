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
			case let .success((data, httpURLResponse)):
				if httpURLResponse.statusCode != 200 {
					completion(.failure(Error.invalidData))
				} else if httpURLResponse.statusCode == 200 {
					do {
						let root = try JSONDecoder().decode(FeedImageRoot.self, from: data)
						if root.items.count == 0 {
							completion(.success([]))
						}
					} catch {
						completion(.failure(Error.invalidData))
					}
				}
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}
