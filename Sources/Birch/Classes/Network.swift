//
//  Network.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

class Network {

    struct Constants {
        static let DEFAULT_HOST = "birch.ryanfung.com"
        static var HOST = DEFAULT_HOST
    }

    private let apiKey: String
    private let configuration: Configuration
    private let http: HTTP
    private let fileManager = FileManager.default

    init(
        apiKey: String,
        configuration: Configuration = Configuration(),
        http: HTTP = HTTP()
    ) {
        self.apiKey = apiKey
        self.configuration = configuration
        self.http = http
    }

    func uploadLogs(url: URL, callback: @escaping (Bool) -> Void) throws {
        Utils.safeIgnore {
            if Birch.debug {
                Birch.d { "[Birch] Pushing logs \(url.lastPathComponent)" }
            }

            if let requestUrl = self.createURL(path: self.configuration.uploadPath),
               let file = self.fileManager.contents(atPath: url.path)
            {
                try self.http.post(
                    url: requestUrl,
                    file: file,
                    headers: ["X-API-Key": self.apiKey]
                ) { response in
                    if response.unauthorized {
                        Birch.e { "[Birch] Invalid API key." }
                    } else {
                        if Birch.debug {
                            Birch.d { "[Birch] Upload logs responded. success=\(response.success)" }
                        }
                        callback(response.success)
                    }
                }
            }
        }
    }

    func syncSource(source: Source, callback: @escaping () -> Void = {}) {
        Utils.safeIgnore {
            if Birch.debug {
                Birch.d { "[Birch] Pushing source." }
            }

            if let requestUrl = self.createURL(path: self.configuration.sourcePath),
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
                        Birch.e { "[Birch] Invalid API key." }
                    } else {
                        if Birch.debug {
                            Birch.d { "[Birch] Sync source responded. success=\(response.success)" }
                        }
                        callback()
                    }
                }
            }
        }
    }

    func getConfiguration(source: Source, callback: @escaping ([String: Any]) -> Void) {
        Utils.safeIgnore {
            if Birch.debug {
                Birch.d { "[Birch] Fetching source configuration." }
            }

            if let requestUrl = self.createURL(path: String(format: self.configuration.configurationPath, source.uuid)) {
                self.http.get(
                    url: requestUrl,
                    headers: [
                        "X-API-Key": self.apiKey,
                        "Content-Type": "application/json"
                    ]
                ) { response in
                    if response.unauthorized {
                        Birch.e { "[Birch] Invalid API key." }
                    } else if response.success {
                        if Birch.debug {
                            Birch.d { "[Birch] Get configuration responded. success=\(response.success)" }
                        }

                        if let dict = Utils.jsonToDictionary(input: response.body),
                           let sourceConfig = dict["source_configuration"] as? [String: Any] {
                            callback(sourceConfig)
                        }
                    }
                }
            }
        }
    }

    struct Configuration {
        let host: String
        let uploadPath: String
        let sourcePath: String
        let configurationPath: String

        init(
            host: String = Constants.HOST,
            uploadPath: String = "/api/v1/logs",
            sourcePath: String = "/api/v1/sources",
            configurationPath: String = "/api/v1/sources/%@/configuration"
        ) {
            self.host = host
            self.uploadPath = uploadPath
            self.sourcePath = sourcePath
            self.configurationPath = configurationPath
        }
    }
}

private extension Network {
    func createURL(path: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = configuration.host
        components.path = path
        return components.url
    }
}
