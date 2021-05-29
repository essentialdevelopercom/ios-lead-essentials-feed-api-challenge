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
			guard self != nil else {
				return
			}
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(FeedItemsMapper.map(data: data, response: response))
			}
		}
	}
}

// MARK: - FeedItemsMapper
private final class FeedItemsMapper {
	struct Root: Decodable {
		let items: [Image]

		var collection: [FeedImage] {
			return items.map { $0.image }
		}
	}

	struct Image: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var image: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.collection)
	}
}
