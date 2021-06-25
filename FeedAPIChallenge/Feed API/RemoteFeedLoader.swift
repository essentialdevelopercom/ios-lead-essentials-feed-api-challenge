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
				if let items = try? FeedImagesMapper.map(data, response) {
					completion(.success(items))
				} else {
					completion(.failure(.invalidData as Error))
				}
			case .failure:
				completion(.failure(.connectivity as Error))
			}
		}
	}
}

private struct FeedImagesMapper {
	
	private struct Root: Decodable {
		let items: [Image]
	}
	
	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.items.map({ $0.item })
	}
}
