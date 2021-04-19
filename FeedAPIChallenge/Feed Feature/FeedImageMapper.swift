import Foundation

internal final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [ImageItem]
	}

	private struct ImageItem: Decodable {
		let image_id: UUID
		let image_description: String?
		let image_location: String?
		let image_url: URL

		var item: ImageItem {
			return ImageItem(
				image_id: image_id,
				image_description: image_description,
				image_location: image_location,
				image_url: image_url
			)
		}
	}

	private static var OK_200: Int { return 200 }

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200, let _ = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success([])
	}
}
