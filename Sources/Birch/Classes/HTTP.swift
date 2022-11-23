//
//  HTTP.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

protocol SessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask
}

class DefaultSession: SessionProtocol {
    let session = URLSession.shared

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return session.dataTask(with: request, completionHandler: completionHandler)
    }

    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        return session.uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
    }
}

class HTTP {
    struct Constants {
        static let LINE = "\r\n"
    }

    let session: SessionProtocol!

    init(session: SessionProtocol = DefaultSession()) {
        self.session = session
    }

    func get(
        url: URL,
        headers: [String: String] = [:],
        onResponse: @escaping (Response) -> Void
    ) {
        let request = createRequest(method: "GET", url: url, headers: headers)
        let semaphore = DispatchSemaphore(value: 0)
        session.dataTask(with: request) { data, response, _ in
            if let response = response as? HTTPURLResponse, let data = data, let body = String(data: data, encoding: .utf8) {
                onResponse(Response(statusCode: response.statusCode, body: body))
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }

    func post(
        url: URL,
        body: String,
        headers: [String: String] = [:],
        onResponse: @escaping (Response) -> Void
    ) {
        var request = createRequest(method: "POST", url: url, headers: headers)
        request.httpBody = body.data(using: .utf8)
        let semaphore = DispatchSemaphore(value: 0)
        session.dataTask(with: request) { data, response, _ in
            if let response = response as? HTTPURLResponse, let data = data, let body = String(data: data, encoding: .utf8) {
                onResponse(Response(statusCode: response.statusCode, body: body))
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }

    func post(
        url: URL,
        file: Data,
        headers: [String: String] = [:],
        onResponse: @escaping (Response) -> Void
    ) {
        let boundary = UUID().uuidString
        let mergedHeaders = ["Content-Type": "multipart/form-data; boundary=\(boundary)"].merging(headers) { (current, _) in current }
        let request = createRequest(method: "POST", url: url, headers: mergedHeaders)
        var body = Data()
        body.append("--\(boundary)\(Constants.LINE)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"logs\"; filename=\"logs.txt\"\(Constants.LINE)\(Constants.LINE)".data(using: .utf8)!)
        body.append(file)
        body.append("--\(boundary)--\(Constants.LINE)".data(using: .utf8)!)
        let semaphore = DispatchSemaphore(value: 0)
        session.uploadTask(with: request, from: body) { data, response, _ in
            if let response = response as? HTTPURLResponse, let data = data, let body = String(data: data, encoding: .utf8) {
                onResponse(Response(statusCode: response.statusCode, body: body))
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }

    struct Response {
        let statusCode: Int
        let body: String

        var unauthorized: Bool {
            return statusCode == 401
        }

        var success: Bool {
            return (100...399).contains(statusCode)
        }

        var failure: Bool {
            return statusCode >= 400
        }
    }
}

private extension HTTP {
    func createRequest(method: String, url: URL, headers: [String: String]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        headers.forEach { info in
            request.addValue(info.value, forHTTPHeaderField: info.key)
        }
        return request
    }
}
