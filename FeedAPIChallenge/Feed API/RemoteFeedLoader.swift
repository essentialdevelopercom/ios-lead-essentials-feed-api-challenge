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
            switch result {
            case let .success((data, response)):
                completion((self?.mapSuccessResult(data, response))!)
            default:
                completion(.failure(Error.connectivity))
                break
            }
        }
    }
    
    private func mapSuccessResult(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == 200, let decodedData = try? JSONDecoder().decode(FeedImageArray.self, from: data) else {
            return .failure(Error.invalidData)
        }
        return .success(decodedData.feedImages)
    }
}

struct FeedImageArray: Decodable {
    private let items: [Item]
    
    var feedImages: [FeedImage] {
        return items.map { $0.item }
    }
}

private struct Item: Decodable {
    let image_id: UUID
    let image_desc: String?
    let image_loc: String?
    let image_url: URL
    
    var item: FeedImage {
        return FeedImage(id: image_id,
                         description: image_desc,
                         location: image_loc,
                         url: image_url
        )
    }
}
