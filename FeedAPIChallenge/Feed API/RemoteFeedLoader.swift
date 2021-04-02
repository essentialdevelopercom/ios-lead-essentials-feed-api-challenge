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
				guard response.statusCode == 200, let _ = try? JSONDecoder().decode(FeedImageMapper.Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success([]))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct FeedImageMapper {
	
	internal struct Root: Codable {
		var items: [Item]
		var images: [FeedImage] {
			return items.compactMap({ $0.item })
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
	}
	
}
