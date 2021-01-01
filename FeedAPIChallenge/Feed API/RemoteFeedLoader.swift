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
			case .success((let data, let response)):
				guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
					return completion(.failure(Error.invalidData))
				}
				
				completion(.success(root.feed))
				break
			case .failure(_):
				completion(.failure(Error.connectivity))
				break
			}
		}
	}
	
	private struct Root: Decodable {
		var items: [Item]
		
		var feed: [FeedImage] {
			return items.map { $0.item }
		}
	}
	
	private struct Item: Decodable {
		var image_id: UUID
		var image_desc: String?
		var image_loc: String?
		var image_url: URL
		
		var item: FeedImage {
			FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
}
