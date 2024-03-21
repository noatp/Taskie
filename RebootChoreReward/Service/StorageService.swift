//
//  StorageService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/14/24.
//

import FirebaseStorage

enum ImageUploadError: Error {
    case imageDataCreationFailed
}

class StorageService {
    let storage = Storage.storage()
    
    func uploadImage(_ image: UIImage) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw ImageUploadError.imageDataCreationFailed
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await imageRef.putDataAsync(imageData, metadata: metadata) { progress in
        }
        
        return try await imageRef.downloadURL()
    }
    
    func uploadImages(_ images: [UIImage]) async throws -> [URL] {
        return try await withThrowingTaskGroup(of: URL.self, body: { taskGroup in
            var urls: [URL] = []
            
            for image in images {
                taskGroup.addTask {
                    return try await self.uploadImage(image)
                }
            }
            
            for try await url in taskGroup {
                urls.append(url)
            }
            
            return urls
        })
    }

}


