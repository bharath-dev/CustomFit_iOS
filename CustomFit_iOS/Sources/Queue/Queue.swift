//
//  Queue.swift
//  CustomFit
//
//  Created by Rajtharan G on 22/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

class CFQueue<Element> {
    
    public init(elements: Array<Element>) {
        for element in elements {
            enqueue(element)
        }
    }
    
    private class Node<Element> {
        
        let value: Element
        weak var previous: Node?
        var next: Node?
        
        public init(_ value: Element) {
            self.value = value
        }
    }
    
    private var head: Node<Element>?
    private var tail: Node<Element>?
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var size: Int {
        var count = 0
        var current = head
        while (current != nil) {
            current = current?.next
            count += 1
        }
        return count
    }
    
    public var elements: [Element] {
        get {
            var result: [Element] = []
            
            var current = head
            while let node = current {
                result.append(node.value)
                current = node.next
            }
            
            return result
        }
    }
    
    public var reversedElements: [Element] {
        get {
            var result: [Element] = []
            
            var current = tail
            while let node = current {
                result.append(node.value)
                current = node.previous
            }
            
            return result
        }
    }
    
    public func enqueue(_ element: Element) {        
        let newNode = Node(element)
        tail?.next = newNode
        newNode.previous = tail
        
        tail = newNode
        
        if head == nil {
            head = tail
        }
    }
    
    public func dequeue() -> Element? {
        let element = head
        
        head = element?.next
        
        if head == nil {
            tail = nil
        }
        
        return element?.value
    }
        
}
