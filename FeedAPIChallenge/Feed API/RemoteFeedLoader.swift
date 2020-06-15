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
    
    private struct StatusCodeConstants {
        static var code200 = 200
    }
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { (result) in
            switch result {
            case let .success((_, response)):
                if response.statusCode != StatusCodeConstants.code200 {
                    completion(.failure(Error.invalidData))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
