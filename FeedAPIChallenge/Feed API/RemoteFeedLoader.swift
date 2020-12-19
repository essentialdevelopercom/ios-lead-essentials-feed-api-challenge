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
		client.get(from: url, completion: {[weak self] result in
			guard let self = self else {return}
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(self.map(data, response))
			}
		})
	}
	
	func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
			return .success(root.items.map{$0.item})
		} else {
			return .failure(Error.invalidData)
		}
	}
	
}

struct Root: Decodable {
	var items: [RemoteFeedImage]

}

struct RemoteFeedImage: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
	
	var item: FeedImage {
		return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
	}
}
