//
//  UIScrollViewWrapper.swift
//  GenieD
//
//  Created by OK on 14.03.2023.
//

import SwiftUI


struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {
    
    @Binding var isOpened: Bool
    let onChangeOffset: ((CGFloat)->Void)
    var content: () -> Content

    init(isOpened: Binding<Bool>, onChangeOffset: @escaping (CGFloat)->Void, @ViewBuilder content: @escaping () -> Content) {
        _isOpened = isOpened
        self.onChangeOffset = onChangeOffset
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIScrollViewViewController {
        let vc = UIScrollViewViewController(isOpened: isOpened, onChangeOffset: onChangeOffset, onChangeIsOpen: { value in
            isOpened = value
        })
        vc.hostingController.rootView = AnyView(self.content())
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollViewViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
        viewController.isOpened = isOpened
    }
}

class UIScrollViewViewController: UIViewController, UIScrollViewDelegate {
    
    let onChangeOffset: ((CGFloat)->Void)
    let onChangeIsOpen: ((Bool)->Void)
    var isOpened: Bool {
        didSet {
            onChangeIsOpen(isOpened)
            if isOpened != oldValue {
                if isOpened {
                    scrollToStart(animated: true)
                } else {
                    scrollToEnd(animated: true)
                }
            }
        }
    }
    private var isAnimated = false
    
    private let animationDuration: CGFloat = 0.25
    
    init(isOpened: Bool, onChangeOffset: @escaping (CGFloat)->Void, onChangeIsOpen: @escaping (Bool)->Void) {
        self.isOpened = isOpened
        self.onChangeOffset = onChangeOffset
        self.onChangeIsOpen = onChangeIsOpen
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.contentInsetAdjustmentBehavior = .never
        v.isPagingEnabled = true
        v.bounces = false
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.delegate = self
        return v
    }()

    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))
    
    var endOffset: CGFloat {
         scrollView.contentSize.width - scrollView.bounds.size.width
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)
        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isOpened {
            scrollToStart(animated: false)
        } else {
            scrollToEnd(animated: false)
        }
    }

    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
        ])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        onChangeOffset(scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !isAnimated else { return }
        
        if scrollView.contentOffset.x.rounded() == 0 {
            isOpened = true
        } else if scrollView.contentOffset.x.rounded() >= endOffset.rounded() {
            isOpened = false
        }
    }
    
    func scrollToEnd(animated: Bool) {
        let offset = CGPoint(x: endOffset, y: 0)
        guard offset.x != scrollView.contentOffset.x else { return }
        
        if animated {
            isAnimated = true
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.001) {
                self.isAnimated = false
            }
            UIView.animate(withDuration: animationDuration, animations: {
                self.scrollView.setContentOffset(offset, animated: false)
            })
        } else {
            scrollView.setContentOffset(offset, animated: false)
        }
    }
    
    func scrollToStart(animated: Bool) {
        let offset = CGPoint(x: 0, y: 0)
        guard offset.x != scrollView.contentOffset.x else { return }
        
        if animated {
            isAnimated = true
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.001) {
                self.isAnimated = false
            }
            UIView.animate(withDuration: animationDuration, animations: {
                self.scrollView.setContentOffset(offset, animated: false)
            })
        } else {
            scrollView.setContentOffset(offset, animated: false)
        }
    }
}
