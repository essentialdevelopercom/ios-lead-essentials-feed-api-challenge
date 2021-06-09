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
			guard let self = self else { return }

			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				guard response.statusCode == 200, let images = self.mapped(data: data, response: response) else {
					return completion(.failure(Error.invalidData))
				}
				completion(.success(images))
			}
		}
	}

	private func mapped(data: Data, response: HTTPURLResponse) -> [FeedImage]? {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return nil
		}
		return root.items.toModels()
	}
}

private struct Root: Decodable {
	let items: [RemoteFeedImage]
}

private struct RemoteFeedImage: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
}

extension Array where Element == RemoteFeedImage {
	func toModels() -> [FeedImage] {
		map { FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) }
	}
}
