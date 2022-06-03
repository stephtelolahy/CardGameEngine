//
//  File.swift
//  
//
//  Created by TELOLAHY Hugues Stéphano on 02/06/2022.
//

import Foundation
import Combine

public class RandomAI {
    
    private var cancellables: [Cancellable] = []
    private var moveCounter = 0
    
    public init() {}
    
    public func observe(game: GameProtocol) {
        cancellables.append(game.state.sink { [unowned self] in processState($0, game: game) })
    }
    
    private func processState(_ state: State, game: GameProtocol) {
        
        if let message = state.lastEvent {
            if message is Move {
                moveCounter += 1
                print("\(moveCounter) - \(String(describing: message))")
            } else {
                print("\t\(String(describing: message))")
            }
        }
        
        if let decision = state.decisions.first?.value,
           let bestMove = decision.options.randomElement() {
            DispatchQueue.main.async {
                game.input(bestMove)
            }
        }
    }
}
