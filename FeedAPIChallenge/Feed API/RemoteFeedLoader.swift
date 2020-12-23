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
			case .failure(_):
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				guard response.statusCode == 200 else {
					return completion(.failure(Error.invalidData))
				}
				guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
					return completion(.failure(Error.invalidData))
				}
				completion(.success(root.images))
			}
		}
	}
}

private struct Root: Decodable {
	private let items: [Item]

	var images: [FeedImage] {
		return items.map({$0.image})
	}
}

private struct Item: Decodable {

	private let id: UUID
	private let description: String?
	private let location: String?
	private let url: URL

	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}

	var image: FeedImage {
		return FeedImage(id: id, description: description, location: location, url: url)
	}
}
