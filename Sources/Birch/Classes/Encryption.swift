//
//  Encryption.swift
//  Birch
//
//  Created by Ryan Fung on 12/14/22.
//

import Foundation
import Security

class Encryption {

    struct Constants {
        static let KEY_SIZE = 32
        static let IV_SIZE = 16
    }

    static func create(publicKey: String) -> Encryption? {
        if let base64 = Data(base64Encoded: publicKey),
           let pem = String(data: base64, encoding: .utf8),
           let secKey = Utils.parsePublicKey(pem: pem) {
            return Encryption(publicKey: secKey)
        } else {
            assertionFailure("The public key you provided is not correct. Please double check this value or remove the public key to disable device level encryption.")
            return nil
        }
    }

    private let publicKey: SecKey
    private let symmetricKey: Data = Encryption.secureRandomData(length: Constants.KEY_SIZE)
    private var aes: AES?

    let encryptedKey: String

    init(publicKey: SecKey) {
        self.publicKey = publicKey
        self.encryptedKey = Encryption.encryptRSA(publicKey: publicKey, input: symmetricKey)
    }

    func encrypt(input: String) -> String {
        do {
            let iv: Data = Encryption.secureRandomData(length: Constants.IV_SIZE)

            if let aes = aes {
                aes.iv = iv.bytes
            } else {
                aes = try AES(key: symmetricKey, iv: iv)
            }

            if let data = input.data(using: .utf8),
               let bytes = try aes?.encrypt(bytes: data.bytes) {
                var combined = Data()
                combined.append(iv)
                combined.append(Data(bytes: bytes, count: bytes.count))
                return combined.base64EncodedString()
            } else {
                return input
            }
        } catch {
            return input
        }
    }

}

private extension Encryption {
    static func secureRandomData(length: Int) -> Data {
        var bytes = [Int8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        return Data(bytes: bytes, count: length)
    }

    static func encryptRSA(publicKey: SecKey, input: Data) -> String {
        let buffer = input.bytes
        var keySize = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)
        _ = SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize)
        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
    }
}
