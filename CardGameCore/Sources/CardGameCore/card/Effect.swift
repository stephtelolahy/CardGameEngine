//
//  Effect.swift
//  
//
//  Created by TELOLAHY Hugues Stéphano on 30/05/2022.
//

/// Effects are card abilities that update the game state
/// The process of resolving an efect is similar to a depth-first search
public protocol Effect: Event {
    func resolve(ctx: State, actor: String, selectedArg: String?) -> EffectResult
}

public enum EffectResult {
    
    /// Resolved with an updated `State`, remove it from queue
    case success(State)
    
    /// Failed with an `Error`, remove it from queue
    /// Returned error must implement `Event` protocol
    case failure(Error)
    
    /// Partially resolved, replace it with child effects
    case resolving([Effect])
    
    /// Suspended waiting user decision among an array of `Move`, keep it in queue
    case suspended([String: [Move]])
    
    /// Remove first effect matching a predicate
    case remove((Effect) -> Bool, Error)
    
    /// Nothing happens, remove it from queue, do not mention it
    case nothing
}
