//
//  Move.swift
//  
//
//  Created by TELOLAHY Hugues Stéphano on 31/05/2022.
//

/// Moves are actions a player chooses to take on their turn while nothing is happening
/// such as playing a card, using your Hero Power and ending your turn
public protocol Move: Event {
    
    var actor: String { get }
    
    func dispatch(state: State) -> MoveResult
}

public enum MoveResult {
    
    case success(state: State, effects: [Effect]?, selectedArg: String?)
    
    case failure(Error)
}
