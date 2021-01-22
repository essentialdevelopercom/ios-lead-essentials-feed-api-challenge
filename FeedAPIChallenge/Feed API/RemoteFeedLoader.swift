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
			case let .success((data , response)):
				guard response.statusCode == 200, let json = try? JSONDecoder().decode(Root.self, from: data) else {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
					return
				}
				
				completion(.success(json.images))
				
			default:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
			
		}
	}
	
	private struct Root: Decodable {
		let items: [Image]
		
		var images: [FeedImage] {
			return items.map { $0.image }
		}
	}
	
	private struct Image: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var image: FeedImage {
			FeedImage(id: image_id,
					  description: image_desc,
					  location: image_loc,
					  url: image_url)
		}
	}
}
