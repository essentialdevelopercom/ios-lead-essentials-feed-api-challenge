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

	private static var OK_200: Int { return 200 }

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: self.url) { result in
			switch result {
			case let .success((data, response)):
				guard response.statusCode == RemoteFeedLoader.OK_200 else {
					completion(.failure(Error.invalidData))
					return
				}
				guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(root.images))
			default:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private struct Root: Decodable {
		let items: [Item]

		var images: [FeedImage] {
			return items.map { $0.image }
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		var image: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}
}
