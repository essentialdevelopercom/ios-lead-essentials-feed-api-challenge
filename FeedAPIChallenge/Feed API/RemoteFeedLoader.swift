//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	private var OK_HTTP: Int {
		return 200
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
			guard let `self` = self else { return }
			switch result {
			case .success(let (data, response)):
				guard JSONSerialization.isValidJSONObject(data), response.statusCode == self.OK_HTTP else {
					completion(.failure(Error.invalidData))
					return
				}
				break
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}
