//
//  Sequence.swift
//  
//
//  Created by TELOLAHY Hugues Stéphano on 31/05/2022.
//

/// A Sequence is what begins when a Player Action is taken.
/// Consists of one or more Effects that are resolved in order.
/// It holds player choices during effect resolution
public struct Sequence {
    
    /// who is playing the card
    public let actor: String
    
    /// played card
    public let card: Card
    
    /// parent card triggering this sequence
    public var parentRef: String?
    
    /// pending events
    public var queue: [Effect] = []
    
    /// selected arguments during effect resolution
    public var selectedArgs: [String: String] = [:]
    
    public init(
        actor: String,
        card: Card,
        parentRef: String? = nil,
        queue: [Effect] = []
    ) {
        self.actor = actor
        self.card = card
        self.parentRef = parentRef
        self.queue = queue
    }
}
