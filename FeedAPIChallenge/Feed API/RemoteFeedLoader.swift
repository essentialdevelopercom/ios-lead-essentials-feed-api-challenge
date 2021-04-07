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
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				guard response.statusCode == 200, let root = try? JSONDecoder().decode(FeedImageMapper.Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(root.feed))
			}
		}
	}
}

private struct FeedImageMapper {
	
	internal struct Root: Codable {
		var items: [Item]
		
		var feed: [FeedImage] {
			items.map { $0.item }
		}
	}
	
	internal struct Item: Codable {
		internal let id: UUID
		internal let description: String?
		internal let location: String?
		internal let url: URL
		
		internal var item: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
		
		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
}
