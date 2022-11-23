//
//  TestSession.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation

@testable import Birch

class TestURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
}

class TestURLSessionUploadTask: URLSessionUploadTask {
    override func resume() {}
}

class TestSession: SessionProtocol {
    var statusCode = 200
    var responseBody = "{}"

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "1.0", headerFields: nil)
        let data = responseBody.data(using: .utf8)!
        completionHandler(data, response, nil)
        return TestURLSessionDataTask()
    }

    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "1.0", headerFields: nil)
        let data = responseBody.data(using: .utf8)!
        completionHandler(data, response, nil)
        return TestURLSessionUploadTask()
    }
}
