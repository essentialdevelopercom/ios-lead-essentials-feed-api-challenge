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
        self.client.get(from: self.url, completion: {
            [weak self] response in
            switch response {
            case let .success((data,response)) :
                    return completion(FeedsItemsMapper.map(data, from: response))
            case .failure(_):
                completion(.failure(Error.connectivity))
                
            }
            
        })
    }
}

internal final class FeedsItemsMapper {
    private struct Root: Decodable {
        let items : [Item]
        var image: [FeedImage] {
            return items.map { $0.item }
        }
    }
    
    private struct Item : Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
        var item: FeedImage {
            return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }
    
    private static var OK_200 : Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == FeedsItemsMapper.OK_200 ,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.image)
    }
}
