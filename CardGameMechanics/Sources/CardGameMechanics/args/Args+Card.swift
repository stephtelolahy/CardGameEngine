//
//  Args+Card.swift
//  
//
//  Created by TELOLAHY Hugues Stéphano on 05/06/2022.
//
import CardGameCore

/// Effect's card argument of a player
public extension Args {
    
    /// random hand card
    static let cardRandomHand = "CARD_RANDOM_HAND"
    
    /// all cards
    static let cardAll = "CARD_ALL"
    
    /// select any card
    static let cardSelectAny = "CARD_SELECT_ANY"
    
    /// select a hand card
    static let cardSelectHand = "CARD_SELECT_HAND"
}

extension Args {
    
    static func resolveCard<T: Effect>(
        _ card: String,
        copyWithCard: @escaping (String) -> T,
        chooser: String,
        source: EffectCardSource,
        state: State,
        ctx: PlayContext
    ) -> EffectResult {
        switch resolveCard(card, source: source, state: state, actor: ctx.actor) {
            
        case let .success(data):
            switch data {
            case let .identified(cIds):
                let effects = cIds.map { copyWithCard($0) }
                return .resolving(effects)
                
            case let .selectable(cIds):
                if let selectedId = ctx.selectedArg,
                   cIds.contains(selectedId) {
                    let copy = copyWithCard(selectedId)
                    return .resolving([copy])
                } else {
                    let options = cIds.map { Choose(value: $0, actor: chooser) }
                    return .suspended([chooser: options])
                }
            }
            
        case let .failure(error):
            return .failure(error)
        }
    }
    
    static func isCardResolved(_ card: String, source: EffectCardSource, state: State) -> Bool {
        switch source {
        case let .player(pId):
            let playerObj = state.player(pId)
            return (playerObj.hand + playerObj.inPlay).contains { $0.id == card }
            
        case .store:
            return state.store.contains { $0.id == card }
        }
    }
    
    enum EffectCardSource {
        case player(String)
        case store
    }
    
    enum EffectCardResolved {
        case identified([String])
        case selectable([String])
    }
    
    static func resolveCard(
        _ card: String,
        source: EffectCardSource,
        state: State,
        actor: String
    ) -> Result<EffectCardResolved, Error> {
        switch card {
        case cardRandomHand:
            return resolveRandomHand(source: source, state: state)
            
        case cardAll:
            return resolveAll(source: source, state: state)
            
        case cardSelectAny:
            return resolveSelectAny(source: source, actor: actor, state: state)
            
        case cardSelectHand:
            return resolveSelectHand(source: source, actor: actor, state: state)
            
        default:
            /// assume identified card
            guard isCardResolved(card, source: source, state: state) else {
                fatalError(.cardValueInvalid(card))
            }
            
            return .success(.identified([card]))
        }
    }
}

private extension Args {
    
    static func resolveRandomHand(source: EffectCardSource, state: State) -> Result<EffectCardResolved, Error> {
        guard case let .player(pId) = source else {
            fatalError(.cardSourceInvalid)
        }
        
        let playerObj = state.player(pId)
        guard !playerObj.hand.isEmpty,
              let randId = playerObj.hand.map({ $0.id }).randomElement() else {
            return .failure(ErrorPlayerHasNoCard(player: pId))
        }
        
        return .success(.identified([randId]))
    }
    
    static func resolveAll(source: EffectCardSource, state: State) -> Result<EffectCardResolved, Error> {
        guard case let .player(pId) = source else {
            fatalError(.cardSourceInvalid)
        }
        
        let playerObj = state.player(pId)
        let all = (playerObj.inPlay + playerObj.hand).map { $0.id }
        guard !all.isEmpty else {
            return .failure(ErrorPlayerHasNoCard(player: pId))
        }
        
        return .success(.identified(all))
    }
    
    static func resolveSelectAny(source: EffectCardSource, actor: String, state: State) -> Result<EffectCardResolved, Error> {
        // setup options
        switch source {
        case let .player(pId):
            let playerObj = state.player(pId)
            if playerObj.inPlay.isEmpty {
                // random hand
                if !playerObj.hand.isEmpty,
                   let randId = playerObj.hand.map({ $0.id }).randomElement() {
                    return .success(.identified([randId]))
                } else {
                    return .failure(ErrorPlayerHasNoCard(player: pId))
                }
            } else {
                // select inPlay
                var cards = playerObj.inPlay.map { $0.id }
                if !playerObj.hand.isEmpty {
                    cards.append(Args.cardRandomHand)
                }
                return .success(.selectable(cards))
            }
            
        case .store:
            let cards = state.store.map { $0.id }
            guard !cards.isEmpty else {
                return .failure(ErrorStoreHasNoCard())
            }
            
            if cards.count == 1 {
                return .success(.identified(cards))
            }
            
            return .success(.selectable(cards))
        }
    }
    
    static func resolveSelectHand(source: EffectCardSource, actor: String, state: State) -> Result<EffectCardResolved, Error> {
        guard case let .player(pId) = source else {
            fatalError(.cardSourceInvalid)
        }
        
        let playerObj = state.player(pId)
        let cards = playerObj.hand.map { $0.id }
        guard !cards.isEmpty else {
            return .failure(ErrorPlayerHasNoCard(player: pId))
        }
        
        return .success(.selectable(cards))
    }
}
