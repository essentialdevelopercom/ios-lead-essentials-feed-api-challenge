//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
    static var OK_200: Int { return 200 }
    
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
    
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
                if response.statusCode == RemoteFeedLoader.OK_200,
                    let root = try? JSONDecoder().decode(FeedImagesResponse.self, from: data) {
                    let feedImages = root.items.map { $0.item }
                    completion(.success(feedImages))
                } else {
                    completion(.failure(Error.invalidData))
                }
            }
        }
    }
}


