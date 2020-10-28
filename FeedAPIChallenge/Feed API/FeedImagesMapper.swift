
import Foundation


internal final class FeedImagesMapper {
    
    private let data: Data
    private let response: HTTPURLResponse
    
    init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.response = response
    }
    
    func map() -> FeedLoader.Result {
        if response.statusCode != 200 {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return decodeData()
    }
    
    private func decodeData() -> FeedLoader.Result {
        do {
            let imageResponses = try JSONDecoder().decode(FeedImagesResponse.self, from: data)
            let images = imageResponses.items.map({ mapImageResponseToFeedImage($0) })
            return .success(images)
        } catch {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
    }
    
    private func mapImageResponseToFeedImage(_ imageResponse: FeedImageResponse) -> FeedImage {
        FeedImage(id: imageResponse.id,
                  description: imageResponse.description,
                  location: imageResponse.location,
                  url: imageResponse.url
        )
    }
    
}
