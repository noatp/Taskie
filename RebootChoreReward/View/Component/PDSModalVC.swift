//
//  PDSModalVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import UIKit
import SwiftUI

class PDSModalVC: UIViewController {
    private var childVC: UIViewController
    let defaultHeight: CGFloat = 400
    let dismissableHeight: CGFloat = 200
    let maximumChildViewHeight: CGFloat = UIScreen.main.bounds.height - 64
    var currentChildViewHeight: CGFloat = 400
    var childViewHeightConstraint: NSLayoutConstraint?
    var childViewBottomConstraint: NSLayoutConstraint?
    let maxDimmedAlpha: CGFloat = 0.6
    
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(childVC: UIViewController) {
        self.childVC = childVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(childVC)
        childVC.didMove(toParent: self)
        setUpViews()
        setUpActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowView()
    }
    
    private func setUpViews() {
        view.backgroundColor = .clear
        guard let childView = childVC.view else {
            return
        }
        childView.layer.cornerRadius = 16
        childView.clipsToBounds = true
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmedView)
        view.addSubview(childView)
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        childViewHeightConstraint = childView.heightAnchor.constraint(equalToConstant: defaultHeight)
        childViewBottomConstraint = childView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        childViewHeightConstraint?.isActive = true
        childViewBottomConstraint?.isActive = true
    }
    
    private func setUpActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        //        print("Pan gesture y offset: \(translation.y)")
        
        // get drag direction
        let isDraggingDown = translation.y > 0
        //        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        let newChildViewHeight = currentChildViewHeight - translation.y
        
        switch gesture.state {
        case .changed:
            if newChildViewHeight <= defaultHeight {
                childViewHeightConstraint?.constant = defaultHeight
                childViewBottomConstraint?.constant = 0 + (defaultHeight - newChildViewHeight)
                view.layoutIfNeeded()
                return
            }
            if newChildViewHeight < maximumChildViewHeight {
                childViewBottomConstraint?.constant = 0
                childViewHeightConstraint?.constant = newChildViewHeight
                view.layoutIfNeeded()
                return
            }
        case .ended:
            if newChildViewHeight < dismissableHeight {
                self.animateDismissView()
                return
            }
            animateChildBottomConstraint(0)
            if newChildViewHeight < defaultHeight {
                animateChildViewHeight(defaultHeight)
                return
            }
            if newChildViewHeight < maximumChildViewHeight && isDraggingDown {
                animateChildViewHeight(defaultHeight)
                return
            }
            if newChildViewHeight > defaultHeight && !isDraggingDown {
                animateChildViewHeight(maximumChildViewHeight)
            }
            
        default:
            break
        }
    }
    
    func animateShowView() {
        animateChildBottomConstraint(0)
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateChildViewHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.childViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        currentChildViewHeight = height
    }
    
    func animateChildBottomConstraint(_ verticalPosition: CGFloat){
        UIView.animate(withDuration: 0.3) {
            self.childViewBottomConstraint?.constant = verticalPosition
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismissView() {
        UIView.animate(withDuration: 0.3) {
            self.childViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: true)
        }
    }
}

struct PDSModalVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            PDSModalVC(childVC: AddChoreVC())
        }
        
    }
}
