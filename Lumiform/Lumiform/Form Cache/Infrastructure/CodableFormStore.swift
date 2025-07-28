//
//  CodableFormStore.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import CryptoKit

public final class CodableFormStore: FormStore {

    private struct Cache: Codable {
        let formItem: FormItem
        let timestamp: Date
    }

    private let storeURL: URL
    private let queue = DispatchQueue(label: "com.lumiform.CodableFormStore", qos: .userInitiated, attributes: .concurrent)

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func deleteCachedForm(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL

        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }

            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func insert(_ form: Lumiform.Form, timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL

        queue.async(flags: .barrier) {
            let encoder = JSONEncoder()
            do {
                let encoded = try encoder.encode(Cache(formItem: form.rootPage, timestamp: timestamp))
                try encoded.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL

        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(nil))
            }

            let decoder = JSONDecoder()
            do {
                let decoded = try decoder.decode(Cache.self, from: data)
                completion(.success(Form(rootPage: decoded.formItem)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension CodableFormStore: FormImageDataStore {

    public func insert(_ data: Data, for url: URL, completion: @escaping (FormImageDataStore.InsertionResult) -> Void) {
        let imageFileURL = imageFileURL(for: url)

        queue.async(flags: .barrier) { [weak self] in
            do {
                try self?.createStoreDirectoryIfNeeded()
                try data.write(to: imageFileURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func retrieveData(for url: URL, completion: @escaping (FormImageDataStore.RetrievalResult) -> Void) {
        let imageFileURL = imageFileURL(for: url)

        queue.async {
            guard FileManager.default.fileExists(atPath: imageFileURL.path) else {
                return completion(.success(.none))
            }

            do {
                let data = try Data(contentsOf: imageFileURL)
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func imageFileURL(for url: URL) -> URL {
        storeURL.appending(component: "img\(stableHashValue(for: url.absoluteString))")
    }

    private func stableHashValue(for string: String) -> String {
        let data = Data(string.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func createStoreDirectoryIfNeeded() throws {
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: storeURL.path, isDirectory: &isDir) {
            try FileManager.default.createDirectory(atPath: storeURL.path, withIntermediateDirectories: true)
        }
    }
}
