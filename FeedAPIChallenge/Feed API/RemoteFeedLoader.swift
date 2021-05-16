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
				guard response.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}
				do {
					let _ = try JSONDecoder().decode(Root.self, from: data)
					completion(.success([]))
				} catch {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private struct Root: Decodable {
		var items: [Image]
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
