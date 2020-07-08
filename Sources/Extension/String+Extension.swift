//
//  String+Extension.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 05/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation
extension String {
    func extractUrl() -> String? {
        let splitList = self.split(separator: ",")
        for url in splitList {
            if url.lowercased().contains("next") {
                let url = url.split(separator: ">").first?.replacingOccurrences(of: "<", with: "")
                return url?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
}
