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
        client.get(from: url) {
            [weak self, completion] (result: Result) in
            guard self != nil else {return}
            switch result {
            case let .success((data, response)):
                completion(FeedLoader.Result{
                            try mapToFeedImage((data, response))
                })
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
}

private func mapToFeedImage(_ result: (Data, HTTPURLResponse)) throws ->  [FeedImage] {
    let (data, response) = result
    try throwIfNot200(response: response)
    
    do {
       return try makeFeedImages(data)
    } catch {
        throw RemoteFeedLoader.Error.invalidData
    }
}

private func throwIfNot200(response: HTTPURLResponse) throws {
    guard response.statusCode == 200 else {
        throw RemoteFeedLoader.Error.invalidData
    }
}

private func makeFeedImages(
    decoder: JSONDecoder = JSONDecoder(),
    _ data: Data) throws -> [FeedImage] {
    let r = try decoder.decode(PrivateFeedImage.self, from: data)
    return r.items.compactMap(\.feedimage)
}

struct PrivateFeedImage: Decodable {
    let items:[_FeeedImage]
    /**
     a decoable form XXX API
     {
     "image_id": "a UUID",
     "image_desc": "a description",
     "image_loc": "a location",
     "image_url": "https://a-image.url",
     }     */
    struct _FeeedImage: Decodable {
        
        let image_id: String
        let image_desc: String?
        let image_loc: String?
        let image_url: String
        
        var feedimage: FeedImage?{
            guard let id  = UUID(uuidString: image_id),
                  let url = URL(string: image_url) else {return nil}
            return FeedImage(
                id: id,
                description: image_desc,
                location: image_loc,
                url: url)
        }
    }
}
