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
		client.get(from: url) { (result) in
			switch result {
			case .success((let data, let response)):
				if let _ = try? JSONDecoder().decode(Root.self, from: data), response.statusCode != 200 {
					
				} else {
					completion(.failure(Error.invalidData))
				}
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	let items: [FeedImageItem]
}

private struct FeedImageItem: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let url: URL
}
