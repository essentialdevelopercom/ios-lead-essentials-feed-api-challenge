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
            self.mapCompletionResult(result, completion: completion)
        }
    }
    
    private func mapCompletionResult(_ result: Result<(Data, HTTPURLResponse), Swift.Error>, completion: @escaping (FeedLoader.Result) -> Void) {
        switch result {
        case let .success((data, response)):
            if response.statusCode != 200 || !JSONSerialization.isValidJSONObject(data) {
                completion(.failure(RemoteFeedLoader.Error.invalidData))
            } 
        case .failure:
            completion(.failure(RemoteFeedLoader.Error.connectivity))
        }
    }
}
