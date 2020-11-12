//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImage: Hashable, Decodable {
	public let image_id: UUID
	public let image_description: String?
	public let image_location: String?
	public let image_url: URL
    
	
	public init(image_id: UUID, image_desc: String?, image_loc: String?, image_url: URL) {
		self.image_id = image_id
		self.image_description = image_desc
		self.image_location = image_loc
		self.image_url = image_url
	}
    
}


