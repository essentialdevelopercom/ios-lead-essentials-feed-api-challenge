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
                completion(.failure(RemoteFeedLoader.Error.connectivity))
                
            case .success((let data, let urlResponse)):
                
                if let items = try? FeedItemMapper.map(data: data, response: urlResponse){
                    completion(.success(items))
                }else {
                    completion(.failure(RemoteFeedLoader.Error.invalidData))
                }
                
                 
                
            }
        }
    }
}

private struct Root : Decodable {
    let items : [Item]
}


private struct Item : Decodable {
     let image_id: UUID
     let image_desc: String?
     let image_loc: String?
     let image_url: URL
    
    var item : FeedImage {
        return FeedImage(id:image_id, description: image_desc, location: image_loc, url: image_url)
    }
}


private class FeedItemMapper {
    static func map(data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
        
    }
    
}
