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
			guard let self = self else { return }
			completion(self.map(result))
		}
	}
		
	private func map(_ result: HTTPClient.Result) -> FeedLoader.Result {
		switch result {
		
		case .failure:
			return .failure(Error.connectivity)

		case let .success((data, response)):
			guard StatusCode(response.statusCode) == .OK,
				  let decoded = DecodedFeedImages(data: data) else {
				return .failure(Error.invalidData)
			}
			
			return .success(decoded.images)
		}
	}
}

fileprivate enum StatusCode: Int {
	case OK = 200
	init?(_ int: Int) { self.init(rawValue: int) }
}

fileprivate struct DecodedFeedImages {

	let images: [FeedImage]
	
	init?(data: Data) {
		guard let images = Self.decodeFeedImages(from: data) else {
			return nil
		}
		self.images = images
	}
	
	private static func decodeFeedImages(from data: Data) -> [FeedImage]? {
		guard let decoded = try? JSONDecoder().decode(Root.self, from: data) else { return nil }
		return decoded.feedImages
	}
	
	//Remote Feed Image Spec:
	/*
	Property	Type
	image_id	UUID
	image_desc	String (optional)
	image_loc	String (optional)
	image_url	URL
	*/
	private struct RemoteFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var feedImage: FeedImage {
			FeedImage(id: image_id,
					  description: image_desc,
					  location: image_loc,
					  url: image_url)
		}
	}
	
	
	// Payload contract:
	/*
	200 RESPONSE

	{
		"items": [
			{
				"image_id": "a UUID",
				"image_desc": "a description",
				"image_loc": "a location",
				"image_url": "https://a-image.url",
			},
			{
				"image_id": "another UUID",
				"image_desc": "another description",
				"image_url": "https://another-image.url"
			},
			{
				"image_id": "even another UUID",
				"image_loc": "even another location",
				"image_url": "https://even-another-image.url"
			},
			{
				"image_id": "yet another UUID",
				"image_url": "https://yet-another-image.url"
			}
			...
		]
	}

	*/
	private struct Root: Decodable {
		let items: [RemoteFeedImage]
		
		var feedImages: [FeedImage] {
			items.map(\.feedImage)
		}
	}
}
