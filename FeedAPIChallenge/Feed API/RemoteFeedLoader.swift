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
			if self == nil { return }
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 else {
					return completion(.failure(Error.invalidData))
				}
				do {
					let items = try FeedItemMapper.map(data: data)
					completion(.success(items))
				} catch {
					print(error)
					completion(.failure(Error.invalidData))
				}
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct FeedItemMapper {
	struct Root: Decodable {
		let items: [ResponseStruct]

		var feeds: [FeedImage] {
			return items.map { $0.item }
		}

		struct ResponseStruct: Decodable {
			let image_id: UUID
			let image_desc: String?
			let image_loc: String?
			let image_url: URL
			var item: FeedImage {
				FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
			}
		}
	}

	static func map(data: Data) throws -> [FeedImage] {
		let json = try JSONDecoder().decode(FeedItemMapper.Root.self, from: data)
		return json.feeds
	}
}
