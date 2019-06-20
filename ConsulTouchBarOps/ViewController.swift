//
//  ViewController.swift
//  ConsulTouchBarOps
//
//  Created by Paul Banks on 17/06/2019.
//  Copyright © 2019 banks. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var textOut: NSTextFieldCell!
    @IBOutlet weak var urlInput: NSTextField!
    @IBOutlet weak var serviceInput: NSTextField!
    @IBOutlet weak var subsetLInput: NSTextField!
    @IBOutlet weak var subsetRInput: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if urlInput.stringValue == "" {
            urlInput.stringValue = "http://localhost:8500"
        }
        if serviceInput.stringValue == "" {
            serviceInput.stringValue = "api"
        }
        if subsetLInput.stringValue == "" {
            subsetLInput.stringValue = "v1"
        }
        if subsetRInput.stringValue == "" {
            subsetRInput.stringValue = "v2"
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

