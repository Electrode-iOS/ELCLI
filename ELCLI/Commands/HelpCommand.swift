//
//  HelpCommand.swift
//  ELCLI
//
//  Created by Brandon Sneed on 7/27/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation

public class HelpCommand: Command {
    private let cli: CLI
    
    public var name: String { return "--help" }
    public var helpDescription: String { return "" }
    public var failOnUnrecognizedOptions: Bool { return false }
    
    public var verbose: Bool = false
    public var quiet: Bool = false
    
    public func configureOptions() {
        // do nothing
    }
    
    public func execute(otherParams: Array<String>?) -> Int {
        write(.Stdout, "usage: ")
        write(.Stdout, "\(NSProcessInfo.processInfo().processName) ")
        writeln(.Stdout, "<command> [<args>]\n")

        writeln(.Stdout, "The most commonly used \(cli.appName) commands are:")
        
        let commands = cli.commands
        for index in 0..<commands.count {
            printCommand(commands[index])
        }
        
        writeln(.Stdout, "")
        
        return 0
    }
    
    init(cli: CLI) {
        self.cli = cli
    }
    
}
