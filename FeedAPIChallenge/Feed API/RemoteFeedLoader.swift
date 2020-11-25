//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
    
    private let statusCodeOk: Int = 200
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
                
            case let .success((data, response)):
                if response.statusCode != self?.statusCodeOk {
                    completion(.failure(Error.invalidData))
                
                } else if (try? JSONSerialization.jsonObject(with: data, options: [])) != nil {
                    completion(.success([]))
                } else {
                    completion(.failure(Error.invalidData))
                }
            }
        })
    }
}
