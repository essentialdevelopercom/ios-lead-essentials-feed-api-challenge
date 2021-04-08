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
			guard self != nil else { return }
			switch result {
			case let .success(_, response):
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
				}
				return 
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct ImageItems: Decodable {
	private let items: [ImageItem]

	private var images: [FeedImage] {
		return items.map { $0.imageItem }
	}

	private struct ImageItem: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL

		var imageItem: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: image)
		}
	}
}
