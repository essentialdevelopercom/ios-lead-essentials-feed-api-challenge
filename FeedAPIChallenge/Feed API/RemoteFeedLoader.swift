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
		client.get(from: url) {[weak self] result in
			guard let self = self else { return }
			if let (data, response) = try? result.get() {
				completion(self.toFeedLoaderResult(data, response))
			}else{
				completion(.failure(Error.connectivity))
			}
		}
	}
	private func toFeedLoaderResult(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		if response.statusCode == validStatusCode {
			return convert(data)
		}else{
			return .failure(Error.invalidData)
		}
	}
	private var validStatusCode: Int { 200 }
	private func convert(_ data: Data) -> FeedLoader.Result {
		if let root = try? JSONDecoder().decode(Root.self, from: data) {
			return .success(root.items.map({$0.feedImage}))
		}else{
			return .failure(Error.invalidData)
		}
	}
}
private struct Root: Decodable {
	let items: [Item]
}
private struct Item: Decodable {
	let image_id: UUID
	let image_url: URL
	let image_desc: String?
	let image_loc: String?
	
	var feedImage: FeedImage {
		FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
	}
}
