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
        client.get(from: url){[weak self] result in
            guard self != nil else { return }
            
            switch result
            {
            case let .success(data,response) :
                completion(FeedImageMapper.map(data,from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
        
    }
    
    private struct Root: Decodable {
      private var items: [Image]
      var feed: [FeedImage] { items.map { $0.feedImage } }
    }

    private struct Image: Decodable {
      private let id: UUID
      private let description: String?
      private let location: String?
      private let url: URL

      var feedImage: FeedImage {
        return FeedImage(image_id: id, image_desc: description, image_loc: location, image_url: url)
      }

      private enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
      }
    }
    
   
    
    
}
