//
//  HTTPClient.swift
//  FeedAPIChallenge
//
//  Created by Christophe Bugnon on 04/09/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
