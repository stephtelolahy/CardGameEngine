//
//  GameTests.swift
//  
//
//  Created by TELOLAHY Hugues Stéphano on 02/06/2022.
//

import XCTest
import Combine
import ExtensionsKit
@testable import CardGameCore

class GameTests: XCTestCase {
    
    private var cancellables: [Cancellable] = []
    
    func test_ProcessLeafSequenceFirst() {
        // Given
        let e1 = DummyEffect(id: "e1")
        let e2 = DummyEffect(id: "e2")
        let e3 = DummyEffect(id: "e3")
        let e4 = DummyEffect(id: "e4")
        let ctx1 = SequenceNode(effect: e1, actor: "p1")
        let ctx2 = SequenceNode(effect: e2, actor: "p2")
        let ctx3 = SequenceNode(effect: e3, actor: "p3")
        let ctx4 = SequenceNode(effect: e4, actor: "p4")
        let sut = Game(State(), sequences: [ctx4, ctx3, ctx2, ctx1])
        var messages: [Event] = []
        cancellables.append(sut.state.sink { messages.append($0.lastEvent) })
        
        // When
        sut.loopUpdate()
        
        // Assert
        XCTAssertEqual(messages, [e4,
                                  e3,
                                  e2,
                                  e1])
    }
    
    func test_AskPossibleMoves_IfPlayReqVerified() {
        // Given
        let c1 = Card().withId("c1")
        let c2 = Card().withId("c2")
        let p1 = Player(health: 1, inner: [c1], hand: [c2])
        let state = State(players: ["p1": p1], playOrder: ["p2", "p1"], turn: "p1")
        let sut = Game(state)
        var messages: [Event] = []
        cancellables.append(sut.state.sink { messages.append($0.lastEvent) })
        
        // When
        sut.loopUpdate()
        
        // Assert
        XCTAssertEqual(messages, [])
        XCTAssertEqual(sut.state.value.decisions["p1"], [Play(card: "c1", actor: "p1"),
                                                         Play(card: "c2", actor: "p1")])
    }
    
    func test_StopUpdates_IfGameIsOver() {
        // Given
        let c1 = Card()
        let p1 = Player(health: 1, inner: [c1])
        let state = State(players: ["p1": p1], turn: "p1", isGameOver: true)
        let sut = Game(state)
        var messages: [Event] = []
        cancellables.append(sut.state.sink { messages.append($0.lastEvent) })
        
        // When
        sut.loopUpdate()
        
        // Assert
        XCTAssertEqual(messages, [])
        XCTAssertTrue(sut.state.value.decisions.isEmpty)
    }
    
    func test_CheckGameOver_IfIdle() {
        // Given
        let p1 = Player(health: 1)
        let p2 = Player(health: 0)
        let state = State(players: ["p1": p1, "p2": p2])
        let sut = Game(state)
        var messages: [Event] = []
        cancellables.append(sut.state.sink { messages.append($0.lastEvent) })
        
        // When
        sut.loopUpdate()
        
        // Assert
        XCTAssertEqual(messages, [])
        XCTAssertTrue(sut.state.value.isGameOver)
    }
    
}
