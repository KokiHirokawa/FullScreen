import RxSwift
import UIKit
import Unio

final class PlayerViewController: UIViewController {

    let viewStream: PlayerViewStreamType = PlayerViewStream()
    private let disposeBag = DisposeBag()

    private lazy var playerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGestureRecognizer)

        return view
    }()

    private lazy var defaultPlayerViewConstraints = [playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                                     playerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                                     playerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                                                     playerView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16)]

    private lazy var widePlayerViewConstraints = [playerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                                  playerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                                  playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                                  playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                                  playerView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16)]

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(playerView)

        viewStream.output.observable(for: \.playerViewSize)
            .subscribe(onNext: { [weak self] in
                self?.changePlayerViewFrame($0)
            })
            .disposed(by: disposeBag)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        viewStream.input.accept(UIDevice.current.orientation, for: \.traitCollectionDidChange)
    }

    @objc private func didDoubleTap(_ sender: UITapGestureRecognizer) {
        viewStream.input.accept((), for: \.didDoubleTapPlayerView)
    }

    private func changePlayerViewFrame(_ size: PlayerViewStream.PlayerViewSize) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            switch size {
            case .small, .large:
                self?.defaultPlayerViewConstraints.forEach {
                    $0.priority = UILayoutPriority(999)
                    $0.isActive = true
                }
                self?.widePlayerViewConstraints.forEach {
                    $0.priority = UILayoutPriority(1)
                    $0.isActive = false
                }
            case .full:
                self?.defaultPlayerViewConstraints.forEach {
                    $0.priority = UILayoutPriority(1)
                    $0.isActive = false
                }
                self?.widePlayerViewConstraints.forEach {
                    $0.priority = UILayoutPriority(999)
                    $0.isActive = true
                }
            }

            self?.view.layoutIfNeeded()
        }
    }
}
