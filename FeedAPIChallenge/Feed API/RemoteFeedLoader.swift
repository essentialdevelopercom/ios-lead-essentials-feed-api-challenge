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
            case .failure:
                completion(.failure(Error.connectivity))
            
            case let .success((data, response)):
                let result = self.parseRemoteResponse(data: data, response: response)
                completion(result)
                
            }
        }
    }
    
    private func parseRemoteResponse(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
            
        guard response.statusCode == 200 else {
            return .failure(Error.invalidData)
        }
        
        guard let remoteFeed = try? JSONDecoder().decode(RemoteFeed.self, from: data) else {
            return .failure(Error.invalidData)
        }
        
        let feedItems = remoteFeed.items.map { image in
            FeedImage(
                id: UUID(uuidString: image.image_id)!,
                description: image.image_desc,
                location: image.image_loc,
                url: URL(string: image.image_url)!
            )
        }

        return .success(feedItems)
        
    }
    
    private struct RemoteFeed: Decodable {
        struct RemoteFeedImage: Decodable {
            let image_id: String
            let image_desc: String?
            let image_loc: String?
            let image_url: String
        }
        let items: [RemoteFeedImage]
    }
}
