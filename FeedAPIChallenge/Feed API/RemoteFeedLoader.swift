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
				do {
					let feed = try FeedImageMapper.map(data, response)
					completion(.success(feed))
				} catch {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [Item]

		var feed: [FeedImage] {
			items.map { $0.item }
		}
	}

	private struct Item: Decodable {
		let id: String
		let description: String?
		let location: String?
		let url: URL

		var item: FeedImage {
			FeedImage(
				id: UUID(uuidString: id)!,
				description: description,
				location: location,
				url: url
			)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}

		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.feed
	}
}
