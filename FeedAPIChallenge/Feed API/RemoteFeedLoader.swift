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
				let result = RemoteFeedLoader.mapper(data, response)
				completion(result)
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	static func mapper(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		
		guard response.statusCode == 200,
			  let root = try? decoder.decode(Root.self, from: data) else {
			return .failure(Error.invalidData)
		}
		
		return .success(root.items.map({$0.toFeedImage()}))
	}
}

struct Root: Decodable {
	var items: [Feed]
	
	struct Feed: Decodable {
		var imageId: UUID
		var imageDesc: String?
		var imageLoc: String?
		var imageUrl: URL
		
		func toFeedImage() -> FeedImage {
			return FeedImage(id: imageId, description: imageDesc, location: imageLoc, url: imageUrl)
		}
	}
}
