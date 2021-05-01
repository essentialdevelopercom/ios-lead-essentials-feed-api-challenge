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
			guard self != nil else {return}
			switch result {
			case .success((let data, let response)):
				completion(FeedItemsMapper.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	let items: [Item]
	
	var feedImages: [FeedImage] {
		items.map { $0.feedImage }
	}
}

private struct Item: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
	
	var feedImage: FeedImage {
		FeedImage(id: image_id,
				  description: image_desc,
				  location: image_loc,
				  url: image_url)
	}
}

internal final class FeedItemsMapper {
	private static var OK_200: Int { 200 }
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.feedImages)
	}
}
