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
        client.get(from: url){ result in
            switch(result){
            case .failure(_):
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            case .success((let data, let response)):
                completion(FeedImagesMapper.map(data, from: response))
            }
        }
    }
}



private struct FeedImagesMapper: Codable{
    private struct Root: Decodable{
        let items: [Item]
        
        var feedImages: [FeedImage] {
                return items.map { $0.item }
            }
    }
    
    private struct Item: Decodable{
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        var item: FeedImage {
            FeedImage(id: id, description: description, location: location, url: url)
        }
        
        private enum CodingKeys: String, CodingKey{
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result{
        
        guard response.statusCode == 200 else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        do{
            let root = try JSONDecoder().decode(Root.self, from: data)
            return .success(root.feedImages)
        }
        catch{
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
    }
}


