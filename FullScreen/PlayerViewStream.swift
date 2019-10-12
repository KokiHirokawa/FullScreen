import RxCocoa
import RxSwift
import Unio

protocol PlayerViewStreamType: AnyObject {
    var input: InputWrapper<PlayerViewStream.Input> { get }
    var output: OutputWrapper<PlayerViewStream.Output> { get }
}

final class PlayerViewStream: UnioStream<PlayerViewStream.Logic>, PlayerViewStreamType {

    init(extra: Extra = .init()) {
        super.init(input: Input(),
                   state: State(),
                   extra: extra,
                   logic: Logic())
    }
}

extension PlayerViewStream {
    struct Input: InputType {
        let traitCollectionDidChange = PublishRelay<UIDeviceOrientation>()
        let didDoubleTapPlayerView = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let playerViewSize: BehaviorRelay<PlayerViewStream.PlayerViewSize>
    }

    struct State: StateType {
        let orientation = BehaviorRelay<UIDeviceOrientation>(value: .unknown)
        let playerViewSize = BehaviorRelay<PlayerViewStream.PlayerViewSize>(value: .small)
    }

    struct Extra: ExtraType {
    }

    struct Logic: LogicType {
        typealias Input = PlayerViewStream.Input
        typealias Output = PlayerViewStream.Output
        typealias State = PlayerViewStream.State
        typealias Extra = PlayerViewStream.Extra

        let disposeBag = DisposeBag()
    }
}

extension PlayerViewStream.Logic {

    func bind(from dependency: Dependency<Input, State, Extra>) -> Output {
        let state = dependency.state

        dependency.inputObservable(for: \.traitCollectionDidChange)
            .bind(to: state.orientation)
            .disposed(by: disposeBag)

        state.orientation
            .subscribe(onNext: {
                if $0.isPortrait {
                    state.playerViewSize.accept(.small)
                }

                if $0.isLandscape {
                    state.playerViewSize.accept(.large)
                }
            })
            .disposed(by: disposeBag)

        dependency.inputObservable(for: \.didDoubleTapPlayerView)
            .subscribe(onNext: {
                switch state.playerViewSize.value {
                case .small:
                    break
                case .large:
                    state.playerViewSize.accept(.full)
                case .full:
                    state.playerViewSize.accept(.large)
                }
            })
            .disposed(by: disposeBag)

        return Output(playerViewSize: state.playerViewSize)
    }
}

extension PlayerViewStream {
    enum PlayerViewSize {
        case small
        case large
        case full
    }
}
