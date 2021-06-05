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
				if response.statusCode == 200, let json = try? JSONDecoder().decode(Root.self, from: data) {
					completion(.success(FeedImageMapper.map(json.items)))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	let items: [Item]
}

private struct Item: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
}

private final class FeedImageMapper {
	static func map(_ items: [Item]) -> [FeedImage] {
		items.map { FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) }
	}
}
