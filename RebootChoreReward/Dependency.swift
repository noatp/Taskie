//
//  Dependency.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/19/24.
//

class Dependency {
    static let preview: Dependency = {
        let dependency = Dependency(isPreview: true)
        return dependency
    }()
    
    let repository: Repository
    let service: Service
    let viewModel: ViewModel
    let view: View
    
    init(isPreview: Bool = false) {
        self.repository = Repository()
        if isPreview {
            self.service = Service(repository: self.repository, isPreview: true)
        } else {
            self.service = Service(repository: self.repository)
        }
        self.viewModel = ViewModel(service: service)
        self.view = View(viewModel: viewModel)
    }
    
    class Repository {
        lazy var userRepository: UserFirestoreRepository = UserFirestoreRepository()
        lazy var householdRepository: HouseholdFirestoreRepository = HouseholdFirestoreRepository()
        lazy var choreRepository: ChoreFirestoreRepository = ChoreFirestoreRepository()
    }
    
    class Service {
        private let repository: Repository
        
        var storageService: StorageService
        var authService: AuthService
        var userService: UserService
        var householdService: HouseholdService
        var choreService: ChoreService
        
        init(repository: Repository, isPreview: Bool = false) {
            self.repository = repository
            if isPreview {
                self.userService = UserMockService()
                self.choreService = ChoreMockService()
                self.householdService = HouseholdMockService()
                self.storageService = StorageService()
                self.authService = AuthMockService()
            } else {
                self.userService = UserFirestoreService(userRepository: repository.userRepository)
                self.choreService = ChoreFirestoreService(
                    choreRepository: repository.choreRepository,
                    userRepository: repository.userRepository,
                    householdRepository: repository.householdRepository
                )
                self.householdService = HouseholdFirestoreService(
                    householdRepository: repository.householdRepository,
                    userRepository: repository.userRepository
                )
                self.storageService = StorageService()
                self.authService = AuthenticationService(
                    userRepository: repository.userRepository,
                    choreRepository: repository.choreRepository,
                    householdRepository: repository.householdRepository
                )
            }
        }
    }
    
    class ViewModel {
        let service: Service
        
        init(service: Service) {
            self.service = service
        }
    }
    
    class View {
        let viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
    }
}
