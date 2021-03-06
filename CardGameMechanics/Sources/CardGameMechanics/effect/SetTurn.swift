//
//  SetTurn.swift
//  
//
//  Created by TELOLAHY Hugues Stéphano on 05/06/2022.
//
import CardGameCore

/// Set turn
public struct SetTurn: Effect {
    
    private let player: String
    
    public init(player: String) {
        assert(!player.isEmpty)
        
        self.player = player
    }
    
    public func resolve(state: State, ctx: PlayContext) -> EffectResult {
        guard Args.isPlayerResolved(player, state: state) else {
            return Args.resolvePlayer(player,
                                      copyWithPlayer: { SetTurn(player: $0) },
                                      state: state,
                                      ctx: ctx)
        }
        
        var state = state
        state.turn = player
        state.turnPlayed = []
        
        return .success(state)
    }
}
