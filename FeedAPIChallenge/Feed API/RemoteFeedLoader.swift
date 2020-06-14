//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    private static let OK_200 = 200
    
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
            case let .success(data, response):
                guard response.statusCode == RemoteFeedLoader.OK_200
                    else {
                        completion(.failure(Error.invalidData))
                        return
                }
                
                guard let items = try? JSONDecoder().decode(FeedResponse.self, from: data).items
                    else {
                        completion(.failure(Error.invalidData))
                        return
                }
                completion(.success(items.compactMap { FeedImageResponseMapper.map(response: $0) }))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

//MARK: - Response entities
extension RemoteFeedLoader {
    private struct FeedResponse: Codable {
        let items: [FeedImageResponse]
    }
    
    private struct FeedImageResponse: Codable {
        let id: String
        let description: String?
        let location: String?
        let urlString: String
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case urlString = "image_url"
        }
    }
}

//MARK: - Mappers
extension RemoteFeedLoader {
    private struct FeedImageResponseMapper {
        static func map(response: FeedImageResponse) -> FeedImage? {
            guard let uuid = UUID(uuidString: response.id),
                let url = URL(string: response.urlString)
                else { return nil }
            return FeedImage(id: uuid,
                             description: response.description,
                             location: response.location,
                             url: url)
        }
    }
}
