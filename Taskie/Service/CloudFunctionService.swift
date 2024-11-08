//
//  CloudFunctionService.swift
//  Taskie
//
//  Created by Toan Pham on 11/7/24.
//

import FirebaseFunctions

class CloudFunctionService {
    let functions = Functions.functions()

    func addRewardToUserBalance(householdId: String, choreId: String) {
        functions.httpsCallable("addRewardToUserBalance").call(["householdId": householdId, "choreId": choreId]) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            if let data = result?.data as? [String: Any], let message = data["message"] as? String {
                print("Success: \(message)")
            }
        }
    }
}
