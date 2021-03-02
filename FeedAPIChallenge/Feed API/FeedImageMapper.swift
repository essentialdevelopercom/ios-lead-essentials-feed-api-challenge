import Foundation

internal final class FeedImageMapper {
	internal static func map(_ data: Data, with response: HTTPURLResponse) -> FeedLoader.Result {
		if let feedImages = try? JSONDecoder().decode(Root.self, from: data).feedImages, response.isOK_200 {
			return .success(feedImages)
		} else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}

	private struct Root: Decodable {
		private let items: [Item]

		internal var feedImages: [FeedImage] {
			items.map { $0.toFeedImage }
		}
	}

	private struct Item: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL

		internal var toFeedImage: FeedImage {
			FeedImage(
				id: image_id,
				description: image_desc,
				location: image_loc,
				url: image_url
			)
		}
	}
}

private extension HTTPURLResponse {
	var isOK_200: Bool {
		statusCode == 200
	}
}
