//
//  FetchingClient.swift
//  Onit
//
//  Created by Benjamin Sage on 10/2/24.
//

import Foundation

class FetchingClient {
    var baseURL: URL {
        URL(string: "https://physical-intelligence-workers.vercel.app")!
    }

    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 300
        configuration.httpMaximumConnectionsPerHost = 100
        return URLSession(configuration: configuration)
    }()

    let encoder = JSONEncoder()
    let decoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
}
