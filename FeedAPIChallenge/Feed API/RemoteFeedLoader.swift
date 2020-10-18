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
            case let .success((data, response)):
                completion(self.map(data: data, response: response))
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == 200,
              let _ = try? JSONDecoder().decode(Root.self, from: data)
        else {
            return .failure(Error.invalidData)
        }

        return .success([])
    }
    
    private struct Root: Decodable {
        let items: [FeedImage]
    }
}

