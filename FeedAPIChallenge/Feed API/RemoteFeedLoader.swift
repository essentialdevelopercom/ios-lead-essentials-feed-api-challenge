//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
    
    private let REPONSE_CODE_SUCCESS = 200
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case let .success((data, response)):
                guard response.statusCode == self.REPONSE_CODE_SUCCESS,
                    let items = try? JSONDecoder().decode(FeedImagesResponse.self, from: data) else {
                        completion(.failure(Error.invalidData))
                        return
                }
                completion(.success(items.feedImages))
                break
                
            case .failure(_):
                completion(.failure(Error.connectivity))
                break
            }
        }
    }
}

private struct FeedImagesResponse: Codable {
    var items: [FeedImageResponse]
    var feedImages: [FeedImage] {
        items.map { $0.feedImage }
    }

    struct FeedImageResponse: Codable {
        var image_id: UUID
        var image_url: URL
        var image_desc: String?
        var image_loc: String?
        
        var feedImage: FeedImage {
            return FeedImage(id: image_id,
                             description: image_desc,
                             location: image_loc,
                             url: image_url)
        }
    }
}
