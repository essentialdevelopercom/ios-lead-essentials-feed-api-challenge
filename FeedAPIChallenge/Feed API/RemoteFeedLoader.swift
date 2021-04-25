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
        client.get(from: url, completion: {
            switch $0 {
            case .failure:
                completion(.failure(Error.connectivity))
            case .success((_, let response)) where response.statusCode != 200:
                completion(.failure(Error.invalidData))
            case .success((let data, _)):
                do {
                    _ = try JSONDecoder().decode(RemoteFeed.self, from: data)

                    completion(.success([]))
                } catch {
                    completion(.failure(Error.invalidData))
                }
            }
        })
    }
}

private struct RemoteFeed: Decodable {
    struct RemoteFeedImage: Decodable {}

    let items: [RemoteFeedImage]
}
