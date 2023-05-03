//
//  ViewController.swift
//  AsyncDemo
//
//  Created by Aiwei on 2023/4/13.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        testDomin.testCase()
    }
    
    private var testDomin: Testable.Type {
        Chapter2.self
    }
}

