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
			case let .success((data, response)):
				completion(
					Result { try map(data, response) }
				)
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	let items: [DecodableFeedImage]
}

private struct DecodableFeedImage: Decodable {
	let imageId: UUID
	let imageLoc: String?
	let imageDesc: String?
	let imageUrl: URL

	var feedImage: FeedImage {
		FeedImage(id: imageId, description: imageDesc, location: imageLoc, url: imageUrl)
	}
}

private func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
	guard response.statusCode == 200 else {
		throw RemoteFeedLoader.Error.invalidData
	}
	do {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		let root = try decoder.decode(Root.self, from: data)
		return root.items.map(\.feedImage)
	} catch {
		throw RemoteFeedLoader.Error.invalidData
	}
}
