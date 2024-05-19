//
//  PickProfileColorViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 5/9/24.
//

import Foundation
import Combine

enum PickProfileColorViewModelError: Error, LocalizedError {
    case missingProfileColor
    
    var errorDescription: String? {
        switch self {
            case .missingProfileColor:
                return "Please pick a color for your profile."
        }
    }
}

class PickProfileColorViewModel: ObservableObject {
    @Published var colorCheckResult: Result<Void, PickProfileColorViewModelError>?
    
    private var userService: UserService
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userService: UserService
        
    ) {
        self.userService = userService
    }
    
    func updateUserWithProfileColor(_ profileColor: String?) {
        guard let profileColor = profileColor, !profileColor.isEmpty else {
            self.colorCheckResult = .failure(.missingProfileColor)
            return
        }
        userService.updateUserWithProfileColor(profileColor)
        self.colorCheckResult = .success(())
    }
    
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension Dependency.ViewModel {
    func pickProfileColorViewModel() -> PickProfileColorViewModel {
        return PickProfileColorViewModel(
            userService: service.userService
        )
    }
}
