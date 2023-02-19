//
//  Network.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

class Network {

    struct Constants {
        static let UPLOAD_PATH = "/api/v1/logs"
        static let SOURCE_PATH = "/api/v1/sources"
        static let CONFIGURATION_PATH = "/api/v1/sources/%@/configuration"
    }

    private let agent: Agent
    private let host: String
    private let apiKey: String
    private let http: HTTP
    private let fileManager = FileManager.default

    init(
        agent: Agent,
        host: String,
        apiKey: String,
        http: HTTP = HTTP()
    ) {
        self.agent = agent
        self.host = host
        self.apiKey = apiKey
        self.http = http
    }

    func uploadLogs(url: URL, callback: @escaping (Bool) -> Void) throws {
        Utils.safeIgnore {
            self.agent.debugStatement { "[Birch] Pushing logs \(url.lastPathComponent)" }

            if let requestUrl = self.createURL(path: Constants.UPLOAD_PATH),
               let file = self.fileManager.contents(atPath: url.path)
            {
                try self.http.post(
                    url: requestUrl,
                    file: file,
                    headers: ["X-API-Key": self.apiKey]
                ) { response in
                    if response.unauthorized {
                        self.agent.e { "[Birch] Invalid API key." }
                    } else {
                        self.agent.debugStatement { "[Birch] Upload logs responded. success=\(response.success)" }

                        callback(response.success)
                    }
                }
            }
        }
    }

    func syncSource(source: Source, callback: @escaping () -> Void = {}) {
        Utils.safeIgnore {
            self.agent.debugStatement { "[Birch] Pushing source." }

            if let requestUrl = self.createURL(path: Constants.SOURCE_PATH),
               let body = Utils.dictionaryToJson(input: ["source": source.toJson()])
            {
                self.http.post(
                    url: requestUrl,
                    body: body,
                    headers: [
                        "X-API-Key": self.apiKey,
                        "Content-Type": "application/json"
                    ]
                ) { response in
                    if response.unauthorized {
                        self.agent.e { "[Birch] Invalid API key." }
                    } else {
                        self.agent.debugStatement { "[Birch] Sync source responded. success=\(response.success)" }
                        callback()
                    }
                }
            }
        }
    }

    func getConfiguration(source: Source, callback: @escaping ([String: Any]) -> Void) {
        Utils.safeIgnore {
            self.agent.debugStatement { "[Birch] Fetching source configuration." }

            if let requestUrl = self.createURL(path: String(format: Constants.CONFIGURATION_PATH, source.uuid)) {
                self.http.get(
                    url: requestUrl,
                    headers: [
                        "X-API-Key": self.apiKey,
                        "Content-Type": "application/json"
                    ]
                ) { response in
                    if response.unauthorized {
                        self.agent.e { "[Birch] Invalid API key." }
                    } else if response.success {
                        self.agent.debugStatement { "[Birch] Get configuration responded. success=\(response.success)" }

                        if let dict = Utils.jsonToDictionary(input: response.body),
                           let sourceConfig = dict["source_configuration"] as? [String: Any] {
                            callback(sourceConfig)
                        }
                    }
                }
            }
        }
    }
}

private extension Network {
    func createURL(path: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        return components.url
    }
}
