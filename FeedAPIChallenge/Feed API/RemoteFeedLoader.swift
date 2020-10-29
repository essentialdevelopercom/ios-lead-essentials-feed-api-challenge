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
                completion(FeedImagesMapper.map(data: data, response: response))
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

internal final class FeedImagesMapper {
    
    private struct Item : Decodable {
        public let image_id : UUID
        public let image_desc : String?
        public let image_loc : String?
        public let image_url : URL
        
        var feedImage : FeedImage {
            return FeedImage(id: self.image_id,
                             description: self.image_desc,
                             location: self.image_loc,
                             url: self.image_url)
        }
    }

    private struct Root : Decodable {
        private let items : [Item]
        
        var images : [FeedImage] {
            return self.items.map { $0.feedImage }
        }
    }
    
    private static var successStatusCode : Int { return 200 }
    
    static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == successStatusCode, let root = try? JSONDecoder().decode(Root.self, from: data)
        else { return .failure(RemoteFeedLoader.Error.invalidData) }
        
        return .success(root.images)
    }
}

