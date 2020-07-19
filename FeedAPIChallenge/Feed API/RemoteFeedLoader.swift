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
            case let .success(data, response):
                if response.statusCode == 200, let _ = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
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
