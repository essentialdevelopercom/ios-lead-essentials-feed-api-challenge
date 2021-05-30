//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

private struct Root: Decodable {
	let items: [FeedItem]
}

private struct FeedItem: Decodable {
	private let id: UUID
	private let description: String?
	private let location: String?
	private let url: URL

	var feedImage: FeedImage {
		FeedImage(id: id, description: description, location: location, url: url)
	}

	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}
}

private class FeedItemMapper {
	static func map(data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return root.items.map { $0.feedImage }
	}
}

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
			case let .success((data, response)):
				do {
					try completion(.success(FeedItemMapper.map(data: data, from: response)))
				} catch {
					completion(.failure(error))
				}
			case .failure: completion(.failure(Error.connectivity))
			}
		}
	}
}
