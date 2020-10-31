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
    
    enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case desc = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
    
    public struct Root : Decodable {
        let items : [FeedImage]
        
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
//        self.client.get(from: self.url) { _ in
//            completion(.failure(Error.connectivity))
//        }
        self.client.get(from: self.url) { [weak self] result in
            guard let _ = self else { return }
            
            switch result {
//            case .success(_, let response):
            case .success((let data, let response)):
                if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                } else {
//                    completion(.failure(Error.connectivity))
//                    let obj = try? JSONDecoder().decode(FeedImage.self, from: data)
//                    let obj = try? JSONDecoder().decode(Root.self, from: data)
//
//                    if obj == nil {
                    do {
                        let obj = try JSONDecoder().decode(Root.self, from: data)
                        completion(.success(obj.items))
                    } catch {
                        completion(.failure(Error.invalidData))
//                    } else {
//                        completion(.success([]))
                    }
                }
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
