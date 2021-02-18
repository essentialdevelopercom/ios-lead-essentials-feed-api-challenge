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
			case .success((let data, let response)):
				completion(RemoteFeedLoaderMapper.map(data, from: response))
			default:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
}

internal struct RemoteFeedLoaderMapper {
	private static var OK_200 = 200
	
	static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200, let feed = try? JSONDecoder().decode(Feed.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(feed.images)
	}
	
	private struct Feed: Decodable {
		let items: [FeedItem]
		
		var images: [FeedImage] {
			return items.compactMap({ $0.feedImage})
		}
	}
	
	private struct FeedItem: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var feedImage: FeedImage {
			FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
}
