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
        client.get(from: self.url) {
            [completion] (result: Result) in
            switch result {
            case let .success((_, response)):
                completion(FeedLoader.Result{try mapToFeedImage((Data(), response))})
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
}

private func mapToFeedImage(_ result: (Data, HTTPURLResponse)) throws ->  [FeedImage] {
    guard result.1.statusCode == 200 else {
        throw RemoteFeedLoader.Error.invalidData
    }
    return []
}
