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
    
    private struct Root: Codable{
        let items: [FeedImageParseModel]
    }
    
    private struct FeedImageParseModel: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        public init(id: UUID, description: String?, location: String?, url: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.url = url
        }
    }
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result{
            case .failure(_):
                completion(.failure(Error.connectivity))
            case let .success( (data, response)):
                guard response.statusCode == 200,
                      let _ = try? JSONDecoder().decode(Root.self, from: data)
                else{
                    completion(.failure(Error.invalidData))
                    return
                }
                completion(.success(.init()))
            }
        })
    }
}


