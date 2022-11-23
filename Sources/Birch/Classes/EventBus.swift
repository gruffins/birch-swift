//
//  EventBus.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

protocol EventBusListener {
    func onEvent(event: EventBus.Event)
}

class EventBus {

    enum Event {
        case sourceUpdate(Source)
    }

    private var listeners: Set<AnyHashable> = Set()


    func subscribe<P>(listener: P) where P: EventBusListener, P: Hashable {
        _ = listeners.insert(listener)
    }

    func unsubscribe<P>(listener: P) where P: EventBusListener, P: Hashable {
        _ = listeners.remove(listener)
    }

    func publish(event: Event) {
        listeners.forEach { ($0 as? EventBusListener)?.onEvent(event: event) }
    }
}
