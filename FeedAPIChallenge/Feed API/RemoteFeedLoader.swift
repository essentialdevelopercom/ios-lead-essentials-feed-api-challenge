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
			case let .success((data, httpURLResponse)):
				if httpURLResponse.statusCode == 200,
				   let remoteFeedImages = RemoteFeedLoader.parse(data: data) {
					completion(.success(RemoteFeedLoader.map(remoteFeedImages)))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private static func parse(data: Data) -> [RemoteFeedImage]? {
		return try? JSONDecoder().decode(RemoteFeedImageResponse.self, from: data).items
	}

	private static func map(_ remoteFeedImages: [RemoteFeedImage]) -> [FeedImage] {
		return remoteFeedImages.map({
			return FeedImage(
				id: $0.image_id,
				description: $0.image_desc,
				location: $0.image_loc,
				url: $0.image_url
			)
		})
	}
}
