//
//  SignUpViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation
import Combine

enum SignUpInfoState {
    case notChecked
    case checked
    case invalid(errorMessage: String)
}

class SignUpViewModel: ObservableObject {
    @Published var infoState: SignUpInfoState = .notChecked
        
    private var authService: AuthService
    private var householdService: HouseholdService
    private var userService: UserService
    private var householdIdFromUniversalLink: String?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authService: AuthService,
        householdService: HouseholdService,
        userService: UserService
        
    ) {
        self.authService = authService
        self.householdService = householdService
        self.userService = userService
        subscribeToHouseholdService()
    }
    
    private func subscribeToHouseholdService() {
        householdService.householdIdReceivedFromLink.sink { [weak self] householdId in
            LogUtil.log("From HouseholdService -- householdId -- \(householdId)")
            self?.householdIdFromUniversalLink = householdId
        }
        .store(in: &cancellables)
    }
    
    func checkEmailForSignUp(_ email: String?){
        guard let email = email, !email.isEmpty else {
            self.infoState = .invalid(errorMessage: "Please enter a valid email address.")
            return
        }
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isValid = emailPredicate.evaluate(with: email)
        
        if isValid {
            authService.cacheEmailAddressForSignUp(email)
            self.infoState = .checked
        }
        else {
            self.infoState = .invalid(errorMessage: "Please enter a valid email address.")
        }
    }
    
    func checkPasswordForSignUp(_ password: String?) {
        guard let password = password, !password.isEmpty else {
            self.infoState = .invalid(errorMessage: "Please enter a valid password.")
            return
        }
        
        guard password.count >= 8 else {
            self.infoState = .invalid(errorMessage: "Password must be at least 8 characters.")
            return
        }
        
        guard password.range(of: "[A-Z]", options: .regularExpression) != nil else {
            self.infoState = .invalid(errorMessage: "Password must have at least one uppercase letter.")
            return
        }
        
        guard password.range(of: "[a-z]", options: .regularExpression) != nil else {
            self.infoState = .invalid(errorMessage: "Password must have at least one lowercase letter.")
            return
        }
        
        authService.cachePassowrdForSignUp(password)
        self.signUp()
        self.infoState = .checked
    }
    
    func signUp() {
        self.authService.signUp()
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension Dependency.ViewModel {
    func signUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(
            authService: service.authService,
            householdService: service.householdService,
            userService: service.userService
        )
    }
}
