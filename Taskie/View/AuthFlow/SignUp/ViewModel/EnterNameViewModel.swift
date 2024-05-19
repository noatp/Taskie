//
//  EnterNameViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 5/9/24.
//

import Foundation
import Combine

enum EnterNameViewModelError: Error, LocalizedError {
    case missingName
    
    var errorDescription: String? {
        switch self {
            case .missingName:
                return "Please enter your name."
        }
    }
}

class EnterNameViewModel: ObservableObject {
    @Published var nameCheckResult: Result<Void, EnterNameViewModelError>?
    
    private var userService: UserService
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userService: UserService
        
    ) {
        self.userService = userService
    }
    
    func checkNameForSignUp(_ name: String?) {
        guard let name = name, !name.isEmpty else {
            self.nameCheckResult = .failure(.missingName)
            return
        }
        userService.updateUserWithName(name)
        self.nameCheckResult = .success(())
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
