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
				guard response.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(RemoteFeedMapper.map(data))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct RemoteFeedMapper {
	private struct Root: Decodable {
		let items: [Image]
	}
	
	private struct Image: Decodable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: String
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
	
	static func map(_ data: Data) -> FeedLoader.Result {
		guard let _ = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success([])
	}
}
