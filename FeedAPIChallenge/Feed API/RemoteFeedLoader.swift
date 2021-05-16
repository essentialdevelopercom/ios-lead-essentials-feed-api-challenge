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
			case let .success((data, response)):
				completion(FeedImageMapper.map(data: data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

class FeedImageMapper {
	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feedImages)
	}

	private struct Root: Decodable {
		var items: [Image]

		var feedImages: [FeedImage] {
			items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
		}
	}

	private struct Image: Decodable {
		var id: UUID
		var description: String?
		var location: String?
		var url: URL

		private enum CodingKeys: String, CodingKey {
			case id = "image_id", description = "image_desc", location = "image_loc", url = "image_url"
		}
	}
}
