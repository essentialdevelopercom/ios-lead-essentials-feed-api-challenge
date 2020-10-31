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
            case .success((let data, let response)):
                guard response.statusCode == 200 else {
                    completion(.failure(Error.invalidData))
                    return
                }
                guard let _ = try? JSONDecoder().decode(AnyDecodable.self, from: data) else {
                    completion(.failure(Error.invalidData))
                    return
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
struct AnyDecodable: Decodable {}
