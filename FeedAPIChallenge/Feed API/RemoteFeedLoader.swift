//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation
public enum HTTPClientResult {
	case success(HTTPURLResponse)
	case failure(Error)
}

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	public typealias Result = FeedLoader.Result
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
		
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from:  url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, _)):
				if let _ = try? JSONSerialization.jsonObject(with: data) {
					completion(.success([]))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
