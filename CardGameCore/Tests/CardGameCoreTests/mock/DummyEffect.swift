//
//  DummyEffect.swift
//  
//
//  Created by TELOLAHY Hugues Stéphano on 02/06/2022.
//
@testable import CardGameCore

struct DummyEffect: Effect {
    
    let id: String
    
    func resolve(state: State, ctx: PlayContext) -> EffectResult {
        .success(state)
    }
}
