//
//  ViewController.swift
//  Counter
//
//  Created by Muker on 6/4/24.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class CounterViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    
    private lazy var decreaseButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "minus.circle.fill")
        config.baseBackgroundColor = .systemRed
        config.buttonSize = .large
        var button = UIButton(configuration: config)
        return button
    }()
    
    private lazy var increaseButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.image = UIImage(systemName: "plus.circle.fill")
        config.buttonSize = .large
        var button = UIButton(configuration: config)
        return button
    }()
    
    private let valueLabel: UILabel = {
        var label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 40, weight: .black)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        var view = UIActivityIndicatorView(style: .large)
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func bind(reactor: CounterViewReactor) {
        // Action
        increaseButton.rx.tap
            .throttle(
                .milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .map { Reactor.Action.increase }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .throttle(
                .milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .map { Reactor.Action.decrease }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.value }
            .distinctUntilChanged()
            .map { "\($0)" }
            .bind(to: valueLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$alertMessage)
            .compactMap { $0 }
            .subscribe(
                with: self,
                onNext: { vc, message in
                    let alertController = UIAlertController(
                        title: nil,
                        message: message,
                        preferredStyle: .alert
                    )
                    alertController.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: .default,
                            handler: nil
                        )
                    )
                    vc.present(
                        alertController,
                        animated: true
                    )
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        [
            decreaseButton,
            increaseButton,
            valueLabel,
            activityIndicatorView
        ]
            .forEach {
                view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
        
        NSLayoutConstraint.activate([
            decreaseButton.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            decreaseButton.leftAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leftAnchor,
                constant: 10
            ),
            increaseButton.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            increaseButton.rightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.rightAnchor,
                constant: -10
            ),
            valueLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            valueLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            activityIndicatorView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            activityIndicatorView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -100
            )
        ])
    }


}

