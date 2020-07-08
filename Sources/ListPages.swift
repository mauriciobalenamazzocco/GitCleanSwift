//
//  ListPages.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 04/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

struct ListPage<T> {
    let items: [T]
    let currentPage: String
    let hasNext: Bool

    init(items: [T], page: String, hasNext: Bool) {
        self.items = items
        self.currentPage = page
        self.hasNext = hasNext
    }

    static func first(items: [T], page: String, hasNext: Bool) -> ListPage<T> {
        return ListPage<T>(items: items, page: page, hasNext: hasNext)
    }

    func with(nextPage: ListPage<T>) -> ListPage<T> {
        return ListPage(
            items: self.items + nextPage.items,
            page: nextPage.currentPage,
            hasNext: nextPage.hasNext
        )
    }
}
