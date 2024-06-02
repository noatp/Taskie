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
        lazy var userRepository: UserRepository = UserRepository()
        lazy var householdRepository: HouseholdRepository = HouseholdRepository()
        lazy var choreRepository: ChoreRepository = ChoreRepository()
        lazy var invitationRepository: InvitationRepository = InvitationRepository()
        lazy var chatMessageRepository: ChatMessageRepository = ChatMessageRepository()
    }
    
    class Service {
        private let repository: Repository
        
        var storageService: StorageService
        var authService: AuthService
        var userService: UserService
        var householdService: HouseholdService
        var choreService: ChoreService
        var chatMessageService: ChatMessageService
        
        init(repository: Repository, isPreview: Bool = false) {
            self.repository = repository
            if isPreview {
                self.userService = UserMockService()
                self.choreService = ChoreMockService()
                self.householdService = HouseholdMockService()
                self.storageService = StorageService()
                self.authService = AuthMockService()
                self.chatMessageService = ChatMessageMockService()
            } else {
                self.authService = AuthenticationService(
                    userRepository: repository.userRepository,
                    choreRepository: repository.choreRepository,
                    householdRepository: repository.householdRepository,
                    invitationRepository: repository.invitationRepository
                )
                self.userService = UserFirestoreService(userRepository: repository.userRepository, householdRepository: repository.householdRepository)
                self.householdService = HouseholdFirestoreService(
                    householdRepository: repository.householdRepository,
                    userRepository: repository.userRepository,
                    invitationRepository: repository.invitationRepository
                )
                self.choreService = ChoreFirestoreService(
                    choreRepository: repository.choreRepository,
                    userRepository: repository.userRepository,
                    householdRepository: repository.householdRepository
                )
                self.storageService = StorageService()
                self.chatMessageService = ChatMessageFirestoreService(
                    choreRepository: repository.choreRepository,
                    chatMessageRepository: repository.chatMessageRepository
                )
                
            }
        }
    }
    
    class ViewModel {
        let service: Service
        let mapper: ModelMapper
        
        init(
            service: Service
        ) {
            self.service = service
            self.mapper = ModelMapper(service: service)
        }
        
        class ModelMapper {
            let choreMapper: ChoreMapper
            let chatMessageMapper: ChatMessageMapper
            
            init(service: Service) {
                self.choreMapper = ChoreMapper(userService: service.userService)
                self.chatMessageMapper = ChatMessageMapper(userService: service.userService)
            }
        }
    }
    
    class View {
        let viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
    }
}
