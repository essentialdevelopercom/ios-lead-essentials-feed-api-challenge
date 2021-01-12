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
			case .success(let data, let response):
				if response.statusCode != 200 {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				} else {
					do {
						let images = try JSONDecoder().decode([FeedImage].self, from: data)
						completion(.success(images))
					} catch {
						completion(.failure(RemoteFeedLoader.Error.invalidData))
					}
				}
			default:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
}

