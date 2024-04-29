//
//  Household.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

import FirebaseFirestore

struct Household: Codable {
    static let empty = Household(id: "")
    static let mock = Household(
        id: "some id", inviteCode: "123456"
    )
    
    let id: String
    let inviteCode: String?
    let inviteCodeExpirationTime: CodableTimestamp?
    
    init(
        id: String,
        inviteCode: String? = nil,
        inviteCodeExpirationTime: CodableTimestamp? = nil
    ) {
        self.id = id
        self.inviteCode = inviteCode
        self.inviteCodeExpirationTime = inviteCodeExpirationTime
    }
}


struct CodableTimestamp: Codable {
    var date: Date
    
    init(from timestamp: Timestamp) {
        self.date = timestamp.dateValue()
    }
    
    init(from date: Date) {
        self.date = date
    }
    
    // Codable implementation to encode/decode as a date.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.date = try container.decode(Date.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(date)
    }
    
    // Helper to convert back to Firebase Timestamp
    var firebaseTimestamp: Timestamp {
        return Timestamp(date: date)
    }
}
