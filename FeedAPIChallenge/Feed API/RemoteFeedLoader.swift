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
					completion(map(data, from: response))
				case .failure:
					completion(.failure(Error.connectivity))
			}
		}
	}
}

fileprivate func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
	guard response.statusCode == 200,
		  let root = try? JSONDecoder().decode(Root.self, from: data) else {
		return .failure(RemoteFeedLoader.Error.invalidData)
	}

	return .success(root.feedImages)
}

fileprivate struct Root: Decodable {
	let items: [RawFeedImage]

	var feedImages: [FeedImage] {
		items.map { $0.feedImage }
	}
}

fileprivate struct RawFeedImage: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL

	var feedImage: FeedImage {
		FeedImage(
			id: image_id,
			description: image_desc,
			location: image_loc,
			url: image_url
		)
	}
}
