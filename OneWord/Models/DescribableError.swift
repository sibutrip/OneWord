//
//  DescribableError.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/18/24.
//

protocol DescribableError: Error {
    var errorTitle: String { get }
}
