//
//  CLI.swift
//  THGCLI
//
//  Created by Brandon Sneed on 7/27/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation

#if NOFRAMEWORKS
#else
import THGFoundation
#endif

public class CLI {
    /**
    Initializes the command line interface with app name, version, and description.
    */
    public init(name: String, version: String, description: String) {
        appName = name
        appVersion = version
        appDescription = version
        var commandLine = NSProcessInfo.processInfo().arguments
        executableName = commandLine.removeFirst()
        allArgumentsToExecutable = commandLine
        addCommands([VersionCommand(cli: self), HelpCommand(cli: self)])
    }
    
    public func addCommands(commands: Array<Command>) {
        commands.each {
            $0.configureOptions()
            self.supportedCommands.append($0)
        }
    }
    
    public func run() -> CLIResult? {
        if let allArgumentsToExecutable = allArgumentsToExecutable {
            if let command = identifyCommand(allArgumentsToExecutable) {
                processArguments(allArgumentsToExecutable, command: command)
                return command.execute(nil)
            }
        }
        
        return nil
    }
    
    public let appName: String
    public let appVersion: String
    public let appDescription: String
    public let executableName: String

    public var allArgumentsToExecutable: Array<String>? = nil
    
    public var commands: Array<Command> {
        get {
            return supportedCommands
        }
    }
    
    private func identifyCommand(arguments: Array<String>) -> Command? {
        if (arguments.count < 1) {
            return nil
        }
        
        let name = arguments[0]
        let foundCommands = supportedCommands.filter { (command) -> Bool in
            return command.name == name
        }
        
        if foundCommands.count > 1 {
            assertionFailure("There are multiple commands that use the name '\(name)'!")
        } else if foundCommands.count == 0 {
            exit("unknown command `\(name)'") { () -> Void in
                HelpCommand(cli: self).execute(nil)
            }
        }
        
        if foundCommands.count > 0 {
            return foundCommands[0]
        }

        return nil
    }
    
    private func processArguments(arguments: Array<String>, command: Command) {
        var skipNext = false
        
        for index in 1..<arguments.count {
            let arg = arguments[index]
            
            if isStopMarker(arg) {
                break
            }
            
            // this facilitates '--flag value' type parameters.
            if skipNext {
                skipNext = false
                continue
            }
            
            let options = command.options
            var optionFlag: String! = nil
            
            // is it a flag, like '--flag 'or '--flag value'?
            if isFlag(arg) {
                let matchingOptions = options.filter { (option) -> Bool in
                    if let flags = option.flags {
                        for flagIndex in 0..<flags.count {
                            if arg.hasPrefix(flags[flagIndex]) {
                                // we want to save this for later instead of looking it up again.
                                optionFlag = flags[flagIndex]
                                return true
                            }
                        }
                    }
                    return false
                }
                
                // if the command is to fail on unrecognized options, do that now if applicable.
                if matchingOptions.count == 0 && command.failOnUnrecognizedOptions {
                    // matching failed
                    exit("unknown option `\(arg)' for command `\(command.name)'") { () -> Void in
                        command.showHelp()
                    }
                } else {
                    // matching successful
                    let option = matchingOptions[0]
                    
                    var value: String? = nil
                    
                    // is this option expecting a value?
                    if option.valueSignatures != nil {
                        if arg.hasPrefix(optionFlag + "=") {
                            // is this a "--flag=value" type argument?
                            // if so, break it into its parts.
                            let parts = arg.characters.split(1, allowEmptySlices: false, isSeparator: { return $0 == "=" })
                            if parts.count == 2 {
                                optionFlag = String(parts[0])
                                value = String(parts[1])
                            }
                        } else {
                            // it's a "--flag value" type argument.
                            if index < arguments.count - 1 {
                                value = arguments[index + 1]
                                skipNext = true
                            }
                        }
                    }
                    
                    option.closure(option: optionFlag, value: value)
                }
            } else {
                // well motherfucker, it's not a flag.  lets find our flag-less option that don't have values yet.
                var matchingOptions = options.filter { (option) -> Bool in
                    if option.flags == nil && option.valueSignatures != nil {
                        return true
                    }
                    return false
                }
                
                // anything without a flag gets shoved into the same closure
                if matchingOptions.count > 0 {
                    matchingOptions[0].closure(option: nil, value: arg)
                }
            }
        }
    }
    
    private func isFlag(arg: String) -> Bool {
        return arg.hasPrefix("-")
    }
    
    private func isStopMarker(arg: String) -> Bool {
        return arg == "--"
    }
    
    public var supportedCommands: Array<Command> = []
}

public struct CLIResult {
    public var resultCode: Int? = 0
    public var resultDescription: String?
    public var executedCommand: Command?
    
    public init() {}
}