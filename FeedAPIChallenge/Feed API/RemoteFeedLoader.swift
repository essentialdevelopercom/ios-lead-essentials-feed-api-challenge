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
			case let .success((data, httpResponse)):
				if httpResponse.statusCode == 200,
				   let _ = try? JSONDecoder().decode(Root.self, from: data) {
					completion(.success([]))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		})
	}

	private struct Root: Decodable {
		let items: [APIFeedImage]
	}

	private struct APIFeedImage: Hashable, Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		init(id: UUID, description: String?, location: String?, url: URL) {
			self.id = id
			self.description = description
			self.location = location
			self.url = url
		}
	}
}
