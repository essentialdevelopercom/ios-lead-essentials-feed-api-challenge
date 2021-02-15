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
		client.get(from: url) { [weak self] (result) in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data)
				else {
					completion(.failure(Error.invalidData))
					return
				}
				
				completion(.success(root.feedImages))
				
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private struct Root: Decodable {
		let items: [Item]
		
		var feedImages: [FeedImage] {
			return items.map({ $0.item })
		}
	}
	
	private struct Item: Decodable {
		public let image_id: UUID
		public let image_desc: String?
		public let image_loc: String?
		public let image_url: URL
		
		var item: FeedImage {
			return FeedImage(id: image_id,
							 description: image_desc,
							 location: image_loc,
							 url: image_url)
		}
	}
}
