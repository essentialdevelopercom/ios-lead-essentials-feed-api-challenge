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
				do {
					let items = try FeedImageMapper.map(data, response)
					completion(.success(items))
				} catch {
					completion(.failure(Error.invalidData))
				}
			case .failure(Error.connectivity):
				completion(.failure(Error.connectivity))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private class FeedImageMapper {
	private struct Root: Decodable {
		let items: [Image]
	}

	private struct Image: Decodable {
		// these properties should match the JSON fields
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var item: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	static var OK_200: Int { return 200 }

	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == OK_200 else {
			throw RemoteFeedLoader.Error.invalidData
		}

		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.items.map { $0.item }
	}
}
