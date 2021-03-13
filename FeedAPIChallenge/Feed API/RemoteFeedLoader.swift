//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private var completion: ((FeedLoader.Result) -> Void)? = nil
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		self.completion = completion
		client.get(from: url) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .failure(_):
				self.completion?(.failure(Error.connectivity))
				return
			case .success((let data, let response)):
				if let images = try? JSONDecoder().decode(Item.self, from: data), response.statusCode == 200 {
					self.completion?(.success(images.items))
					return
				} else {
					self.completion?(.failure(Error.invalidData))
					return
				}
			}
		}
	}
}
