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
		client.get(from: url, completion: { result in
			switch result {
			case let .success((data, response)):
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
				} else {
					do {
						let root = try JSONDecoder().decode(Root.self, from: data)
						completion(.success(root.items.map { $0.item }))
					} catch {
						completion(.failure(Error.invalidData))
					}
				}
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		})
	}
}

private struct Root: Decodable {
	let items: [Item]
}

private struct Item: Hashable, Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let url: URL

	var item: FeedImage {
		return FeedImage(id: id, description: description, location: location, url: url)
	}

	init(id: UUID, description: String?, location: String?, url: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}

	private enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}
}
