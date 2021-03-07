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
		client.get(from: url) { [weak self] (result) in
			guard self != nil else { return }
			switch result {
			case .success(( let data, let response)):
				completion(JSONMapper.map(data: data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

struct JSONMapper {
	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		if response.statusCode == 200,
			let images = try? JSONDecoder().decode(Images.self, from: data) {
			return .success(images.items)
		} else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
