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
			guard let self = self else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case .success((let data, let response)):

				guard response.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}

				guard let feedLoaderItems = try? JSONDecoder().decode(FeedItemAPI.self, from: data).items else {
					completion(.failure(Error.invalidData))
					return
				}

				let feedImage = self.feedImagesFactory(feedLoaderItems)
				completion(.success(feedImage))
			}
		}
	}

	private func feedImagesFactory(_ feedImageAPI: [FeedImageAPI]) -> [FeedImage] {
		feedImageAPI.map {
			FeedImage(
				id: $0.image_id,
				description: $0.image_desc,
				location: $0.image_loc,
				url: $0.image_url
			)
		}
	}
}
