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
		self.client.get(from: self.url) { [weak self] result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				switch response.statusCode {
				case 200:
					if let images = self?.images(from: data) {
						completion(.success(images))
					} else {
						completion(.failure(Error.invalidData))
					}
				default:
					completion(.failure(Error.invalidData))
				}
			}
		}
	}

	// MARK: Private methods

	private func images(from data: Data) -> [FeedImage]? {
		let root = try? JSONSerialization.jsonObject(with: data) as? [String: [FeedImage]]
		return root?["items"]
	}
}
