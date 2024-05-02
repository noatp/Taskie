//
//  DocumentReferenceExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import Foundation
import FirebaseFirestore

enum FirestoreError: Error {
    case encodingError
}

extension DocumentReference {
    func setDataAsync<T: Encodable>(from data: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let jsonData = try JSONEncoder().encode(data)
                guard let dictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                    continuation.resume(throwing: FirestoreError.encodingError)
                    return
                }
                self.setData(dictionary) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
