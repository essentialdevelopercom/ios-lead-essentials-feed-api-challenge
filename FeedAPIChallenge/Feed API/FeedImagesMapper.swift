import Foundation

internal struct FeedImagesMapper {

	private static let successStatusCode = 200

	private struct Root: Decodable {
		private let items: [Item]

		var images: [FeedImage] {
			return items.map({$0.image})
		}
	}

	private struct Item: Decodable {

		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}

		var image: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}

	static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {

		guard response.statusCode == successStatusCode else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.images)
	}
}
