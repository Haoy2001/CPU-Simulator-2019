//
//  ALU.swift
//  CPU Simulator 2019
//
//  Created by Hao Yun on 2018-01-11.
//  Copyright © 2018 Hao Yun. All rights reserved.
//

import Foundation
import SpriteKit
import Cocoa

class ALU: Scene {

    var inputBus: Bus?
    var write1: Bus?
    var write2: Bus?
    var read: Bus?
    var subtract: Bus?
    var reg1: Bus?
    var reg2: Bus?
    var regOut: Bus?
    var label: SKLabelNode?
    var resultLabel: SKLabelNode?

    var write1V = 0
    {
        didSet {
            //only write on turning on
            write1?.value = write1V
            if write1V == 1 {
                reg1!.value = inputBus!.value
                updateLabel()
            }
        }
    }
    var write2V = 0
    {
        didSet {
            write2?.value = write2V
            if write2V == 1 {
                reg2!.value = inputBus!.value
                updateLabel()
            }
        }
    }
    var readV = 0
    {
        didSet {
            read?.value = readV
            if readV == 1 {
                inputBus!.value = regOut!.value
            }
        }
    }
    var subtractV = 0


    override init(id: Int, controller: SceneController, bg: String) {

        super.init(id: id, controller: controller, bg: bg)
        inputBus = Bus(x: 160, y: 770, width: 700, height: 100, bits: 16, spacing: 1, scene: self)
        write1 = Bus(x: 900, y: 770, width: 60, height: 100, bits: 1, spacing: 0.4, scene: self)
        write2 = Bus(x: 970, y: 770, width: 60, height: 100, bits: 1, spacing: 0.4, scene: self)
        read = Bus(x: 1040, y: 770, width: 60, height: 100, bits: 1, spacing: 0.4, scene: self)
        subtract = Bus(x: 1110, y: 770, width: 60, height: 100, bits: 1, spacing: 0.4, scene: self)
        reg1 = Bus(x: 160, y: 680, width: 700, height: 40, bits: 16, spacing: 0.4, scene: self)
        reg2 = Bus(x: 160, y: 600, width: 700, height: 40, bits: 16, spacing: 0.4, scene: self)
        regOut = Bus(x: 160, y: 100, width: 700, height: 40, bits: 16, spacing: 0.4, scene: self)
        let box = SKShapeNode(rect: CGRect(x: 360, y: 160, width: 320, height: 320))
        box.fillColor = SKColor.black

        label = SKLabelNode(text: "")
        label?.position = CGPoint(x: 500, y: 350)
        resultLabel = SKLabelNode(text: "0")
        resultLabel?.position = CGPoint(x: 500, y: 280)
        addNode(node: label!)
        addNode(node: resultLabel!)
        addNode(node: box)
    }
    
    override func event(id: Int, data:Array<Int> = []) {
        
        inputBus?.value = 14

        switch id {
        //set write bus 1
        case 1:
            write1V = data[0]
            break
            
        //set write bus 2
        case 2:
            write2V = data[0]
        
        default:
            print("Error")
        }
    }

    //called when scene is active and updated
    override func update(_ currentTime: TimeInterval) {
//        inputBus?.value = Int(arc4random_uniform(65300))
//        inputBus!.value = 8
//        write1V = Int(arc4random_uniform(2))
//        write2V = Int(arc4random_uniform(2))
//        regOut!.value = 12314
//        readV = Int(arc4random_uniform(2))
    }

    func updateLabel() {
        let sign = subtractV == 0 ? "+" : "-"
        let text = "\(reg1!.value ) \(sign) \(reg2!.value )"
        label!.text = text
        
        let result = reg1!.value + reg2!.value
        resultLabel!.text = String(result)
    }
}

