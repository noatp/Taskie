//
//  PickProfileColorViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 5/9/24.
//

import Foundation
import Combine

class PickProfileColorViewModel: ObservableObject {
    @Published var infoState: SignUpInfoState = .notChecked
    
    private var userService: UserService
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userService: UserService
        
    ) {
        self.userService = userService
    }
    
    func updateUserWithProfileColor(_ profileColor: String?) {
        guard let profileColor = profileColor, !profileColor.isEmpty else {
            self.infoState = .invalid(errorMessage: "Please pick a color for your profile.")
            return
        }
        userService.updateUserWithProfileColor(profileColor)
        self.infoState = .checked
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
