//
//  Item.swift
//  IroPedia
//
//  Created by 匿名T on 2024/11/15.
//

import Foundation

struct Item: Identifiable {
    let id = UUID()
    let name: String
    let index: Int
    let type: String
}
