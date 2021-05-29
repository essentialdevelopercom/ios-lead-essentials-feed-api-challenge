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
			case .failure:
				completion(.failure(Error.connectivity))
			case .success(let result):
				let data = result.0
				let response = result.1

				guard response.statusCode == 200,
				      let _ = try? JSONDecoder().decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success([]))
			}
		}
	}
}

// MARK: - Helpers
struct Root: Decodable {
	let items: [Image]

	var collection: [FeedImage] {
		return items.map { $0.image }
	}
}

struct Image: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let url: URL

	var image: FeedImage {
		return FeedImage(id: id, description: description, location: location, url: url)
	}
}
