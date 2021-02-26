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
				do {
					let images = try FeedImagesMapper.map(from: data, response: response)
					completion(.success(images))
				} catch {
					completion(.failure(error))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Item]
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}

		func toFeedImage() -> FeedImage {
			FeedImage(
				id: id,
				description: description,
				location: location,
				url: url
			)
		}
	}
	
	static func map(from data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		if let root = try? JSONDecoder().decode(Root.self, from: data) {
			return root.items.map { $0.toFeedImage() }
		} else {
			throw RemoteFeedLoader.Error.invalidData
		}
	}
}

