//
//  Options.swift
//  THGCLI
//
//  Created by Brandon Sneed on 7/27/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation

public typealias OptionClosure = (option: String?, value: String?) -> Void

public struct Option {
    let usage: String?
    let flags: Array<String>?
    let valueSignatures: Array<String>?
    let closure: OptionClosure
    
    init(flags: Array<String>?, usage: String?, valueSignatures: Array<String>?, closure: OptionClosure) {
        self.flags = flags
        self.usage = usage
        self.valueSignatures = valueSignatures
        self.closure = closure
    }

    init(flags: Array<String>?, usage: String?, closure: OptionClosure) {
        self.flags = flags
        self.usage = usage
        self.valueSignatures = nil
        self.closure = closure
    }

    init(valueSignatures: Array<String>?, closure: OptionClosure) {
        self.flags = nil
        self.usage = nil
        self.valueSignatures = valueSignatures
        self.closure = closure
    }
    
}

