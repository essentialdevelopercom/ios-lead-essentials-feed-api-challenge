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
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success(result):
                self.process(result: result, with: completion)
            }
        }
    }
    
    private func process(result: (data: Data, response: HTTPURLResponse), with completion: @escaping (FeedLoader.Result) -> Void) {
        guard result.response.statusCode == 200 else { return completion(.failure(Error.invalidData)) }
        guard let decodedResponse = try? JSONDecoder().decode(FeedImageResponse.self, from: result.data) else { return completion(.failure(Error.invalidData))
        }
        
        completion(.success(decodedResponse.items.map { $0.toFeedImage }))
    }
}
