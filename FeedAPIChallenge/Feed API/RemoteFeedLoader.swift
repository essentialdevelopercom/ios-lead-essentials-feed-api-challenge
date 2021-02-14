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
			guard let self = self else { return }
			switch result {
			case .failure(_):
				completion(.failure(Error.connectivity))
			case .success((let data, let httpResponse)):
				completion(self.remoteFeedResponseResult(from: data, response: httpResponse))
			}
		})
	}
}

private extension RemoteFeedLoader {
	func remoteFeedResponseResult(from data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
			  let remoteFeedItems = remoteFeedItems(from: data) else  {
			return .failure(Error.invalidData)
		}
		return .success(remoteFeedItems.toFeedImageItems())
	}
	
	func remoteFeedItems(from data: Data) -> RemoteFeedItems?{
		let decoder = JSONDecoder()
		return try? decoder.decode(RemoteFeedItems.self, from: data)
	}
}

private struct RemoteFeedItems: Decodable {
	let items: [RemoteFeed]
	
	func toFeedImageItems() -> [FeedImage] {
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
