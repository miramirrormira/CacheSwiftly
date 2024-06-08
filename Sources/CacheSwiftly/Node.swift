//
//  Node.swift
//  
//
//  Created by Mira Yang on 6/7/24.
//

import Foundation

public protocol Node: AnyObject {
    var next: Node? { get set }
    var prev: Node? { get set }
}
