//
//  Dependency.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/19/24.
//

class Dependency {
    static let preview = Dependency()
    
    let repository = Repository()
    let service = Service()
    let viewModel = ViewModel()
    let view = View()
    
    class Repository {
        lazy var userRepository: UserFirestoreRepository = UserFirestoreRepository()
        lazy var householdRepository: HouseholdFirestoreRepository = HouseholdFirestoreRepository()
        lazy var choreRepository: ChoreFirestoreRepository = ChoreFirestoreRepository()
    }
    
    class Service {
        private let repository: Repository = Repository()
        
        lazy var storageService: StorageService = StorageService()
        lazy var authService: AuthService = AuthService()
        lazy var userService: UserService = UserFirestoreService(userRepository: repository.userRepository)
        lazy var householdService: HouseholdService = HouseholdFirestoreService(householdRepository: repository.householdRepository)
        lazy var choreService: ChoreService = ChoreFirestoreService(choreRepository: repository.choreRepository)
    }
    
    class ViewModel {
        let service: Service = Service()
    }
    
    class View {
        let viewModel: ViewModel = ViewModel()
    }
}
