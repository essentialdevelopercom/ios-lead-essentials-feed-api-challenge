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
			case .success((let data, let response)):
				completion(RemoteFeedLoader.map(data, from: response))
			default:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode != 200, let images = try? JSONDecoder().decode([FeedImage].self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(images)
	}
}
