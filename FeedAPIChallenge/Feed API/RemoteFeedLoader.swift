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
	
    private struct PayloadDTO: Decodable {
        let items: [ImageDTO]
    }

    private struct ImageDTO: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
    }
    
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { (error) in
            switch error {
            case .success((let data, let response)):
                if response.statusCode == 200 {
                    do {
                        let decoder = JSONDecoder()
                        let payload = try decoder.decode(PayloadDTO.self, from: data)
                        completion(.success(RemoteFeedLoader.convert(imageDTOs: payload.items)))
                    } catch {
                        completion(.failure(RemoteFeedLoader.Error.invalidData))
                    }
                } else {
                    completion(.failure(RemoteFeedLoader.Error.invalidData))
                }
            case .failure(_):
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
        }
    }
    
    private static func convert(imageDTOs: [ImageDTO]) -> [FeedImage] {
        return imageDTOs.map({ FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) })
    }
}
