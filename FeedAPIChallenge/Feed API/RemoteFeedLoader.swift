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
		self.client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				completion(RemoteFeedMapper.map(data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct RemoteFeedMapper {
	static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
			  let feed = try? JSONDecoder().decode(RootObject.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(feed.images)
	}
	
	private struct RootObject: Decodable {
		let items: [Image]
		
		var images: [FeedImage] {
			items.compactMap { item in
				FeedImage(id: item.id,
						  description: item.description,
						  location: item.location,
						  url: item.url)
				
			}
		}
	}
	
	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
}
