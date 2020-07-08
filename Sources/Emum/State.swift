//
//  State.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

enum State: Equatable {
    case idle
    case loadingPage
    case loadedPage

    static func == (lhs: State, rhs: State) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loadingPage, .loadingPage):
            return true
        case (.loadedPage, .loadedPage):
            return true
        default:
            return false
        }
    }
}
