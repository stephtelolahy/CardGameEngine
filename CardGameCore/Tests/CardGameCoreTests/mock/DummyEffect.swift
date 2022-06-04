//
//  File.swift
//  
//
//  Created by TELOLAHY Hugues Stéphano on 02/06/2022.
//
@testable import CardGameCore

struct DummyEffect: Effect, Equatable {
    
    let id: String
    
    func resolve(ctx: State, cardRef: String) -> Result<State, Error> {
        var state = ctx
        state.lastEvent = self
        return .success(state)
    }
}
