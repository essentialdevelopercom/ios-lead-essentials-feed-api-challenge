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

    private static var OK_200: Int { return 200 }
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let (data, response)):
                guard response.statusCode == RemoteFeedLoader.OK_200 else {
                    completion(.failure(Error.invalidData))
                    return
                }

                do {
                    try JSONSerialization.jsonObject(with: data)
                    completion(.success([]))
                } catch {
                    completion(.failure(Error.invalidData))
                }

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
