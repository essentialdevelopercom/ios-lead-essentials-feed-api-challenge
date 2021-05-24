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
			guard self != nil else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case .success(let response):

				guard response.1.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}

				guard !response.0.isEmpty else {
					completion(.success([]))
					return
				}

				do {
					let feedLoaderResult = try JSONDecoder().decode(FeedItemAPI.self, from: response.0)
					let feedImage = feedLoaderResult.items.map {
						FeedImage(
							id: $0.id,
							description: $0.description,
							location: $0.location,
							url: $0.url
						)
					}
					completion(.success(feedImage))
				} catch {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}
