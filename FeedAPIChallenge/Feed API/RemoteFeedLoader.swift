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

	private static let OK_200 = 200

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }

			switch result {
			case let .success((data, response)):
				guard response.statusCode == RemoteFeedLoader.OK_200,
				      let feedImages = RemoteFeedLoader.map(data) else {
					return completion(.failure(Error.invalidData))
				}

				completion(.success(feedImages))
			default:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private static func map(_ data: Data) -> [FeedImage]? {
		return try? JSONDecoder().decode(Items.self, from: data).map()
	}

	private final class Items: Decodable {
		fileprivate let items: [FeedAPIImage]

		fileprivate func map() -> [FeedImage] {
			return items.map {
				FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
			}
		}
	}

	private final class FeedAPIImage: Decodable {
		fileprivate let id: UUID
		fileprivate let description: String?
		fileprivate let location: String?
		fileprivate let url: URL

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
}
