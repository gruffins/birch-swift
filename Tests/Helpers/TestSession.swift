//
//  TestSession.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation

@testable import Birch

class TestSession: SessionProtocol {
    var statusCode = 200
    var responseBody = "{}"

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "1.0", headerFields: nil)
        let data = responseBody.data(using: .utf8)!
        completionHandler(data, response, nil)
        
        return URLSession.shared.dataTask(with: clone(request)!)
    }

    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "1.0", headerFields: nil)
        let data = responseBody.data(using: .utf8)!
        completionHandler(data, response, nil)
        
        return URLSession.shared.uploadTask(with: clone(request)!, from: bodyData!)
    }
    
    func clone(_ request: URLRequest) -> URLRequest? {
        guard var comps = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        comps.host = "localhost"
        
        if let url = comps.url {
            var clone = request
            clone.url = url
            return clone
        } else {
            return nil
        }
    }
}
