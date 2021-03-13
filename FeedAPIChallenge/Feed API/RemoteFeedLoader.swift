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
			case .failure(_):
				completion(.failure(Error.connectivity))
				return
			case .success((let data, let response)):
				if let images = try? JSONDecoder().decode([FeedImage].self, from: data), (200..<300).contains(response.statusCode) {
					completion(.success(images))
					return
				} else {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}
