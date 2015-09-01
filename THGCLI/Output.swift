//
//  Output.swift
//  THGCLI
//
//  Created by Brandon Sneed on 8/13/15.
//  Copyright © 2015 TheHolyGrail. All rights reserved.
//

import Foundation

#if NOFRAMEWORKS
#else
import THGFoundation
#endif

public enum Output {
    case Stdin
    case Stdout
    case Stderr
    
    func fileHandle() -> NSFileHandle {
        switch self {
        case Stdin:
            return NSFileHandle.fileHandleWithStandardInput()
        case Stderr:
            return NSFileHandle.fileHandleWithStandardError()
        case Stdout:
            fallthrough
        default:
            return NSFileHandle.fileHandleWithStandardOutput()
        }
    }
}

public func write(destination: Output, _ data: String) {
    var str = data
    if destination == .Stderr {
        str = "error: " + data
    }

    if let outputData = str.dataUsingEncoding(NSUTF8StringEncoding) {
        destination.fileHandle().writeData(outputData)
    }
}

public func writeln(destination: Output, _ data: String) {
    write(destination, data + "\n")
}

public func exitSuccess() {
    if isInUnitTest() {
        exceptionFailure("")
    } else {
        exit(0)
    }
}

public func exit(data: String, closure: (() -> Void)? = nil) {
    writeln(.Stderr, data)
    if let closure = closure {
        closure()
    }
    
    if isInUnitTest() {
        exceptionFailure(data)
    } else {
        exit(1)
    }
}

public func printOption(option: Option) {
    if option.flags == nil || option.valueSignatures?.count > 1 {
        return
    }
    
    var flagData = "     "
    
    if let flags = option.flags {
        for index in 0..<flags.count {
            if index == 0 {
                flagData += flags[index]
            } else {
                flagData += ", " + flags[index]
            }
        }
    }
    
    if let sigs = option.valueSignatures {
        if sigs.count > 0 {
            flagData += " " + sigs[0]
        }
    }
    
    flagData = flagData.padBack(26)
    
    let usageData = option.usage!
    
    if flagData.characters.count > 26 {
        flagData += "\n"
        flagData += usageData.padFront(27 + usageData.characters.count)
    } else {
        flagData += " " + usageData
    }
    
    writeln(.Stdout, flagData)
    
}

public func printCommand(command: Command) {
    if command.name.hasPrefix("-") {
        return
    }
    
    var commandData = "   "
    
    commandData += command.name.padBack(14)
    commandData += " " + command.helpDescription
    
    writeln(.Stdout, commandData)
}

extension String {
    func padFront(maxLength: Int) -> String {
        var spaces = ""
        if maxLength > self.characters.count {
            for _ in 0..<(maxLength - self.characters.count) {
                spaces += " "
            }
        }
        
        return "\(spaces)\(self)"
    }
    
    func padBack(maxLength: Int) -> String {
        var spaces = ""
        if maxLength > self.characters.count {
            for _ in 0..<(maxLength - self.characters.count) {
                spaces += " "
            }
        }
        
        return "\(self)\(spaces)"
    }
}