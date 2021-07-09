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
			case let .success((data, response)):
				completion(FeedImageMapper.map(data, response: response))
			default:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [FeedItem]

		var feedImages: [FeedImage] {
			items.map({ FeedImage(id: $0.uuid, description: $0.description, location: $0.location, url: $0.imageURL) })
		}
	}

	private struct FeedItem: Decodable {
		let uuid: UUID
		let description: String?
		let location: String?
		let imageURL: URL

		enum CodingKeys: String, CodingKey {
			case uuid = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case imageURL = "image_url"
		}
	}

	internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200, let feedItemsRoot = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(feedItemsRoot.feedImages)
	}
}
