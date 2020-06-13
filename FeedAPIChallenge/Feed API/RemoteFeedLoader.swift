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
                
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let items = json["items"] as? [[String: Any]]
                    else {
                        completion(.failure(Error.invalidData))
                        return
                }
                
                let images = items.compactMap { $0.feedImage }
                completion(.success(images))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

//MARK: - Map from json to FeedImage
private extension Dictionary where Key == String, Value == Any {
    var feedImage: FeedImage? {
        guard let id = self["image_id"] as? String,
            let uuid = UUID(uuidString: id),
            let urlString = self["image_url"] as? String,
            let url = URL(string: urlString)
            else { return nil }
        
        return FeedImage(id: uuid,
                         description: self["image_desc"] as? String,
                         location: self["image_loc"] as? String,
                         url: url)
    }
}
