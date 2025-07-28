//
//  CodableFormStore.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

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
