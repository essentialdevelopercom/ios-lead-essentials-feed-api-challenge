//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private static let OK_200 = 200

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
			case let .success((data, response)):
				guard response.statusCode == self.OK_200,
				      let responseItems = try? JSONDecoder().decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(responseItems.feedImages))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	private let items: [FeedImageResponseItem]

	var feedImages: [FeedImage] {
		items.map { FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) }
	}
}

private struct FeedImageResponseItem: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
}
