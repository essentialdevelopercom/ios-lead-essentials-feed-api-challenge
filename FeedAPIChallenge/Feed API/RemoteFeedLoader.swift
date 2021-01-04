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
				completion(FeedImageMapper.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
}


private class FeedImageMapper {
	private struct Root: Decodable {
		var items: [Item]
	}
	
	private struct Item: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL
		
		func toFeedImage() -> FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		if response.statusCode == 200 {
			do {
				let root = try JSONDecoder().decode(Root.self, from: data)
				let feedImages = root.items.map { $0.toFeedImage() }
				return .success(feedImages)
			} catch {
				return .failure(RemoteFeedLoader.Error.invalidData)
			}
		} else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}

