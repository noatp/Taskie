//
//  EnterNameViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 5/9/24.
//

import Foundation
import Combine

class EnterNameViewModel: ObservableObject {
    @Published var infoState: SignUpInfoState = .notChecked
    
    private var userService: UserService
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userService: UserService
        
    ) {
        self.userService = userService
    }
    
    func checkNameForSignUp(_ name: String?) {
        guard let name = name, !name.isEmpty else {
            self.infoState = .invalid(errorMessage: "Please enter your name.")
            return
        }
        userService.updateUserWithName(name)
        self.infoState = .checked
    }
    
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension Dependency.ViewModel {
    func enterNameViewModel() -> EnterNameViewModel {
        return EnterNameViewModel(
            userService: service.userService
        )
    }
}
