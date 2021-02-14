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
		client.get(from: url, completion: { [weak self] (result) in
			guard self != nil else { return }
			switch result {
			case .failure(_):
				completion(.failure(Error.connectivity))
			case .success((let data, let response)):
				if response.statusCode == 200 {
					guard let remoteFeedItems = self?.remoteFeedItems(from: data) else {
						completion(.failure(Error.invalidData))
						return
					}
					completion(.success(remoteFeedItems.toFeedItems()))
				} else {
					completion(.failure(Error.invalidData))
				}
			}
		})
	}
	
	private func remoteFeedItems(from data: Data) -> RemoteFeedItems?{
		let decoder = JSONDecoder()
		return try? decoder.decode(RemoteFeedItems.self, from: data)
	}
}

private struct RemoteFeedItems: Decodable {
	let items: [RemoteFeed]
	
	func toFeedItems() -> [FeedImage] {
		return items.map { (remoteFeed) -> FeedImage in
			return FeedImage(id: remoteFeed.image_id,
							 description: remoteFeed.image_desc,
							 location: remoteFeed.image_loc,
							 url: remoteFeed.image_url)
		}
	}
}

private struct RemoteFeed: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
}
