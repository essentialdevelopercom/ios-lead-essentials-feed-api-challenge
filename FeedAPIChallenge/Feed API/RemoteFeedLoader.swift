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
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				let decoder = JSONDecoder()
				if let root = try? decoder.decode(Root.self, from: data), response.statusCode == 200 {
					completion(.success(root.items.map({FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url)})))
				}else{
					completion(.failure(Error.invalidData))
				}
			}
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
}
