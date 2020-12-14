//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	private enum HTTPStatusCode {
		static var OK: Int { 200 }
	}
	
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
			case let .success((data, httpResponse)):
				guard httpResponse.statusCode == HTTPStatusCode.OK,
							let feedImages = FeedImageDecoder.decode(data: data) else {
					return completion(.failure(Error.invalidData))
				}
				return completion(.success(feedImages))
			default:
				break
			}
			completion(.failure(Error.connectivity))
		}
	}

}
