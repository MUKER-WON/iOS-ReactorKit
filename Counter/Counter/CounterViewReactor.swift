//
//  CounterViewReactor.swift
//  Counter
//
//  Created by Muker on 6/4/24.
//

import ReactorKit

final class CounterViewReactor: Reactor {
    
    enum Action {
        case increase
        case decrease
    }
    
    enum Mutation {
        case increaseValue
        case decreaseValue
        case setLoading(Bool)
        case setAlertMessage(String)
    }
    
    struct State {
        var value: Int
        var isLoading: Bool
        @Pulse var alertMessage: String?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State(
            value: 0,
            isLoading: false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .increase:
            return Observable.concat([
                Observable
                    .just(Mutation.setLoading(true)),
                Observable
                    .just(Mutation.increaseValue)
                    .delay(
                        .milliseconds(500),
                        scheduler: MainScheduler.instance
                    ),
                Observable
                    .just(Mutation.setLoading(false)),
                Observable
                    .just(Mutation.setAlertMessage("increased🔼"))
            ])
        case .decrease:
            return Observable.concat([
              Observable
                .just(Mutation.setLoading(true)),
              Observable
                .just(Mutation.decreaseValue)
                .delay(
                    .milliseconds(500),
                    scheduler: MainScheduler.instance
                ),
              Observable
                .just(Mutation.setLoading(false)),
              Observable
                .just(Mutation.setAlertMessage("decreased!"))
            ])
        }
    }
    
    func reduce(
        state: State,
        mutation: Mutation
    ) -> State {
        var state = state
        switch mutation {
        case .increaseValue:
            state.value += 1
        case .decreaseValue:
            state.value -= 1
        case let .setLoading(isLoading):
            state.isLoading = isLoading
        case let .setAlertMessage(message):
            state.alertMessage = message
        }
        return state
    }
    
}
