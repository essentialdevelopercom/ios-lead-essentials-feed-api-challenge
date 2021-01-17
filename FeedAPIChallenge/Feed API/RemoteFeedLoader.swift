//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private let OK200 = 200

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
				if response.statusCode == self?.OK200,
					let feedItems = try? self?.loadFeedItems(from: data) {
					completion(.success(feedItems))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
    }

	private func loadFeedItems(from data: Data) throws -> [FeedImage] {
		try JSONDecoder().decode(FeedItemsRoot.self, from: data)
			.items
			.map { $0.feedImage }
	}
}

private struct FeedItemsRoot: Decodable {
	let items: [Items]
}

private struct Items: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL

	var feedImage: FeedImage {
		FeedImage(
			id: image_id,
			description: image_desc,
			location: image_loc,
			url: image_url
		)
	}
}
