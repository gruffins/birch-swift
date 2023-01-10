//
//  Source.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

class Source {

    private let storage: Storage
    private let eventBus: EventBus

    let uuid: String
    let packageName: String
    let appVersion: String
    let appBuildNumber: String
    let brand: String
    let manufacturer: String
    let model: String
    let os: String
    let osVersion: String

    private var cache: [String: String]? = nil

    var identifier: String? {
        didSet {
            storage.identifier = identifier
            cache = nil
            eventBus.publish(event: .sourceUpdate(self))
        }
    }

    var customProperties: [String: String]? {
        didSet {
            storage.customProperties = customProperties
            cache = nil
            eventBus.publish(event: .sourceUpdate(self))
        }
    }

    init(storage: Storage, eventBus: EventBus) {
        let meta = Bundle.main.infoDictionary
        let processInfo = ProcessInfo()
        let osv = processInfo.operatingSystemVersion

        self.storage = storage
        self.eventBus = eventBus

        uuid = storage.uuid ?? UUID().uuidString
        packageName = Bundle.main.bundleIdentifier ?? ""
        appVersion = (meta?["CFBundleShortVersionString"] as? String) ?? ""
        appBuildNumber = (meta?["CFBundleVersion"] as? String) ?? ""
        brand = "Apple"
        manufacturer = "Apple"
        model = Utils.getDeviceModel() ?? ""
        osVersion = "\(osv.majorVersion).\(osv.minorVersion).\(osv.patchVersion)"

        storage.uuid = uuid

        #if os(watchOS)
            os = "watchOS"
        #elseif os(tvOS)
            os = "tvOS"
        #elseif os(macOS)
            os = "macOS"
        #else
            os = "iOS"
        #endif
    }

    func toJson() -> [String: String] {
        if let cache = cache {
            return cache
        } else {
            var json: [String: String] = [
                "uuid": uuid,
                "package_name": packageName,
                "app_version": appVersion,
                "app_build_number": appBuildNumber,
                "brand": brand,
                "manufacturer": manufacturer,
                "model": model,
                "os": os,
                "os_version": osVersion,
                "identifier": identifier ?? ""
            ]

            if let customProperties = customProperties {
                customProperties.forEach { info in
                    json["custom_property__\(info.key)"] = info.value
                }
            }

            cache = json
            return json
        }
    }
}
