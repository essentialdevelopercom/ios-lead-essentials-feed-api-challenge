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
				completion(FeedImageMapper.map(data: data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private class FeedImageMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedImage]
	}
	private struct RemoteFeedImage: Decodable {
		public let id: UUID
		public let description: String?
		public let location: String?
		public let url: URL
		
		public init(id: UUID, description: String?, location: String?, url: URL) {
			self.id = id
			self.description = description
			self.location = location
			self.url = url
		}
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
		
		var model: FeedImage {
			return FeedImage(
				id: id,
				description: description,
				location: location,
				url: url
			)
		}
	}
	
	public static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		let items = root.items.map { $0.model }
		return .success(items)
	}
}
