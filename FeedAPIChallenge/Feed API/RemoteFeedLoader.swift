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
        self.client.get(from: self.url) { [weak self] result in
            guard let _ = self else { return }
            
            switch result {
            case .success((let data, let response)):
                if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                } else {
                    do {
                        let object = try JSONDecoder().decode(Root.self, from: data)
                        completion(.success(object.items))
                    } catch {
                        completion(.failure(Error.invalidData))
                    }
                }
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
