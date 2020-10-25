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
            case let .success((data, response)):
                guard response.statusCode == 200 else {
                    completion(.failure(Error.invalidData))
                    return
                }
                guard let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let items = jsonDictionary["items"] as? [Any] else {
                    completion(.failure(Error.invalidData))
                    return
                }
                if items.isEmpty {
                    completion(.success([]))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
