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
				completion(FeedImageMapper.map(data, response))
			default:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

class FeedImageMapper {
	
	private struct Root: Decodable {
		private var items: [Item]
		
		var feedImages: [FeedImage] {
			return items.map {
				FeedImage(id: $0.id,
						  description: $0.description,
						  location: $0.location,
						  url: $0.image)
			}
		}
		
		private struct Item: Decodable {
			var id: UUID
			var description: String?
			var location: String?
			var image: URL
			
			enum CodingKeys: String, CodingKey {
				case id = "image_id"
				case description = "image_desc"
				case location = "image_loc"
				case image = "image_url"
			}
		}
	}
	
	private static var OK_HTTP: Int {
		return 200
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_HTTP,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.feedImages)
	}
	
}
