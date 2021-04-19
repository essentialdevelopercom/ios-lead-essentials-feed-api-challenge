import Foundation

internal final class FeedImageMapper {
	private static var OK_200: Int { return 200 }

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200 else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success([])
	}
}
