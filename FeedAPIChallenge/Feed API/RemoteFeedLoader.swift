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
            case let .success((_, response)) where response.statusCode != 200 :
                completion(.failure(Error.invalidData))
            case let .success((data, _)):
                completion(RemoteFeedLoader.map(data))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    static func map(_ data: Data) -> FeedLoader.Result {
        do {
            _ = try JSONSerialization.jsonObject(with: data)
            return .success([])
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
