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
		client.get(from: url) { result in
			switch result {
			case let .success((data, httpResponse)):
				guard httpResponse.statusCode == HTTPStatusCode.OK,
							let _ = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
					return completion(.failure(Error.invalidData))
				}
			default:
				break
			}
			completion(.failure(Error.connectivity))
		}
	}
}
