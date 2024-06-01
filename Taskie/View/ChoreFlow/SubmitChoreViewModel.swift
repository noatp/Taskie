
//  SubmitChoreViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 5/31/24.
//

import Combine
import UIKit

class SubmitChoreViewModel: ObservableObject {
    @Published var images: [UIImage?] = [nil]

    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        
    }
    
    func add(image: UIImage) {
        images.insert(image, at: 0)
    }
}

extension Dependency.ViewModel {
    func submitChoreViewModel() -> SubmitChoreViewModel {
        return SubmitChoreViewModel()
    }
}
