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
				completion(FeedImagesMapper.map(data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

enum FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Image]

		var feed: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}

	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		var feedImage: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	private static let okayResponseCode = 200

	static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == okayResponseCode,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feed)
	}
}
