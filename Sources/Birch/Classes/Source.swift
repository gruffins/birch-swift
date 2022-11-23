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
    let os: String = "iOS"
    let osVersion: String

    var identifier: String? {
        didSet {
            storage.identifier = identifier
            eventBus.publish(event: .sourceUpdate(self))
        }
    }

    var customProperties: [String: String]? {
        didSet {
            storage.customProperties = customProperties
            eventBus.publish(event: .sourceUpdate(self))
        }
    }

    init(storage: Storage, eventBus: EventBus) {
        let meta = Bundle.main.infoDictionary

        self.storage = storage
        self.eventBus = eventBus

        uuid = storage.uuid ?? UUID().uuidString
        packageName = Bundle.main.bundleIdentifier ?? ""
        appVersion = (meta?["CFBundleShortVersionString"] as? String) ?? ""
        appBuildNumber = (meta?["CFBundleVersion"] as? String) ?? ""
        brand = "Apple"
        manufacturer = "Apple"
        model = Utils.getDeviceModel() ?? ""
        osVersion = UIDevice.current.systemVersion

        storage.uuid = uuid
    }

    func toJson() -> [String: String] {
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
        return json
    }
}
