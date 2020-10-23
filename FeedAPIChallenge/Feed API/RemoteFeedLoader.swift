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
    
    private struct FeedImagesResponse: Codable{
        private let items: [FeedImageParseModel]
        
        public func mapToFeedImages() -> [FeedImage]{
            return items.map({
                FeedImage.init(id: $0.imageId, description: $0.imageDesc, location: $0.imageLoc, url: $0.imageUrl)
            })
        }
    }
    
    private struct FeedImageParseModel: Codable {
        public let imageId: UUID
        public let imageDesc: String?
        public let imageLoc: String?
        public let imageUrl: URL
        
        public init(id: UUID, description: String?, location: String?, url: URL) {
            self.imageId = id
            self.imageDesc = description
            self.imageLoc = location
            self.imageUrl = url
        }
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url, completion: {[weak self] result in
            guard let self = self else{ return }
            switch result{
            case .failure(_):
                completion(.failure(Error.connectivity))
            case let .success( (data, response)):
                completion(self.getFeedImagesResultFor(data: data, response: response))
            }
        })
    }
    
    private func getFeedImagesResultFor(data: Data, response: HTTPURLResponse) -> FeedLoader.Result{
        guard response.statusCode == 200,
              let data = self.decodeFeedImagesResponseFrom(data: data)
        else{
            return .failure(Error.invalidData)
        }
        return .success(data.mapToFeedImages())
    }
    
    private func decodeFeedImagesResponseFrom(data: Data) -> FeedImagesResponse?{
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(FeedImagesResponse.self, from: data)
    }
}


