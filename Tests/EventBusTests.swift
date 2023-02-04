//
//  EventBusTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class Listener: EventBusListener, Hashable, Equatable {
    var events: [EventBus.Event] = []

    func onEvent(event: EventBus.Event) {
        events.append(event)
    }

    static func == (lhs: Listener, rhs: Listener) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

class EventBusTests: QuickSpec {
    override func spec() {
        var listener: Listener!
        var eventBus: EventBus!

        beforeEach {
            listener = Listener()
            eventBus = EventBus()
        }

        describe("publish()") {
            it("publishes to listeners") {
                let source = Source(
                    storage: Storage(
                        directory: "birch",
                        defaultLevel: .error),
                    eventBus: eventBus
                )
                eventBus.subscribe(listener: listener)
                eventBus.publish(event: .sourceUpdate(source))
                expect(listener.events).notTo(beEmpty())
            }

            it("doesnt publish to unsubscribed listeners") {
                let source = Source(
                    storage: Storage(
                        directory: "birch",
                        defaultLevel: .error
                    ),
                    eventBus: eventBus
                )
                eventBus.subscribe(listener: listener)
                eventBus.unsubscribe(listener: listener)
                eventBus.publish(event: .sourceUpdate(source))
                expect(listener.events).to(beEmpty())
            }
        }
    }
}
