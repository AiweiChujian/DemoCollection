//
//  CADisplayLinkHolder.swift
//  LottieDemo
//
//  Created by Aiwei on 2023/2/22.
//

import UIKit

class CADisplayLinkHolder {
    let displayLink: CADisplayLink
    
    init(handler: @escaping (CADisplayLink) -> Void) {
        displayLink = CADisplayLink(target: CADisplayTarget(handler: handler), selector: #selector(CADisplayTarget.displayLinkAction(_:)))
    }

    deinit {
        displayLink.invalidate()
    }
}

fileprivate class CADisplayTarget {
    let handler: (CADisplayLink) -> Void
    
    init(handler: @escaping (CADisplayLink) -> Void) {
        self.handler = handler
    }
    
    @objc func displayLinkAction(_ sender: CADisplayLink) {
        handler(sender)
    }
}
