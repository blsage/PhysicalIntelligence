//
//  FetchingClient+Data.swift
//  Onit
//
//  Created by Benjamin Sage on 10/2/24.
//

import Foundation

extension FetchingClient {
    @discardableResult public func data(
        from url: URL,
        method: HTTPMethod = .get,
        body: Data? = nil,
        contentType: String? = nil,
        additionalHeaders: [String: String]? = nil
    ) async throws -> Data {
        print("fetching from \(url)")
        let request = makeRequest(
            from: url,
            method: method,
            body: body,
            contentType: contentType,
            additionalHeaders: additionalHeaders
        )
        return try await fetchAndHandle(using: request)
    }

    private func makeRequest(
        from url: URL,
        method: HTTPMethod,
        body: Data?,
        contentType: String?,
        additionalHeaders: [String: String]?
    ) -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue
        request.httpBody = body
        request.addContentType(for: method, defaultType: contentType ?? "application/json")

        additionalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func fetchAndHandle(using request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await fetchDataAndResponse(using: request)
            try handle(response: response, withData: data)
            return data
        } catch let error as FetchingError {
            throw error
        } catch {
            throw FetchingError.networkError(error)
        }
    }

    private func fetchDataAndResponse(using request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw FetchingError.invalidResponse
        }

        return (data, httpResponse)
    }

    private func handle(response: HTTPURLResponse, withData data: Data) throws {
        switch response.statusCode {
        case 200...299:
            break
        case 400...499:
            let message = parseErrorMessage(from: data) ?? "Client error occurred."
            if response.statusCode == 401 {
                throw FetchingError.unauthorized
            } else if response.statusCode == 403 {
                throw FetchingError.forbidden(message: message)
            } else if response.statusCode == 404 {
                throw FetchingError.notFound
            } else {
                throw FetchingError.failedRequest(message: message)
            }
        case 500...599:
            let message = parseErrorMessage(from: data) ?? "Server error occurred."
            throw FetchingError.serverError(statusCode: response.statusCode, message: message)
        default:
            let message = parseErrorMessage(from: data) ?? "An unexpected error occurred."
            throw FetchingError.failedRequest(message: message)
        }
    }

    private func parseErrorMessage(from data: Data) -> String? {
        if let errorResponse = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
            return errorResponse.message
        }
        return String(data: data, encoding: .utf8)
    }
}
