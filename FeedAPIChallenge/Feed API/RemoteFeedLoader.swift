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
    self.client.get(from: self.url) { result in
      switch result {
      case .success(let (data, response)):
        guard response.statusCode == 200 else {
          return completion(.failure(Error.invalidData))
        }

        do {
          try JSONDecoder().decode([FeedImageResponse].self, from: data)
        } catch {
          return completion(.failure(Error.invalidData))
        }

      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }

  struct FeedImageResponse: Codable {
    let imageID: String
    let imageDesc: String?
    let imageLOC: String?
    let imageURL: URL

    enum CodingKeys: String, CodingKey {
      case imageID = "image_id"
      case imageDesc = "image_desc"
      case imageLOC = "image_loc"
      case imageURL = "image_url"
    }
  }
}
