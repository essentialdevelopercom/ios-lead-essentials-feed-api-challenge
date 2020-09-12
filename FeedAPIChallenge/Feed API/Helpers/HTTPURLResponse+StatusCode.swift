//
//  HTTPURLResponse+StatusCode.swift
//  FeedAPIChallenge
//
//  Created by Raphael Silva on 12/09/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int {
        return 200
    }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
