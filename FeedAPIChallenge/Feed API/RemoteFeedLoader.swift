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
            guard self != nil else { return }
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                completion(FeedImagesMapper.map(data, from: response))
            }
        }
    }
}

internal final class FeedImagesMapper {
    static var OK_200: Int { return 200 }
    
    private struct FeedImagesResponse: Decodable {
        
        struct FeedImageResponse: Decodable {
            var image_id: UUID
            var image_desc: String?
            var image_loc: String?
            var image_url: URL
            
            var item: FeedImage {
                return FeedImage(id: image_id,
                                 description: image_desc,
                                 location: image_loc,
                                 url: image_url)
            }
        }
        
        let items: [FeedImageResponse]
        var feedImages: [FeedImage] {
            return items.map { $0.item }
        }
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(FeedImagesResponse.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feedImages)
    }
}
