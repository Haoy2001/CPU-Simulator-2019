//
//  ControlUnit.swift
//  CPU Simulator 2019
//
//  Created by Hao Yun on 2018-01-11.
//  Copyright © 2018 Hao Yun. All rights reserved.
//

import Foundation
import SpriteKit
import Cocoa

class ControlUnit: Scene {

    var instructionPointer = 1 {
        didSet {
            instructionPointerLabel.text = "Current Line: \(instructionPointer)"
            indicatorArrow.position = CGPoint(x: 496, y: 589 - Int((Double((instructionPointer - 1)) * 14.1)))
        }
    }

    var currentSpeed = 4 {
        didSet {
            controller.eventQ?.speedMod = speed[currentSpeed]
            speedLabel.text = "Speed: x\(speed[currentSpeed])"
        }
    }

    var running = false {
        didSet {

        }
    }

    var halt = false
    var instructionArray: Array<Array<Int>> = [[]]
    let instructionPointerLabel = SKLabelNode(text: "Current Line: 1")
    let speedLabel = SKLabelNode(text: "Speed: x1.0")
    var indicatorArrow = SKSpriteNode(imageNamed: "arrow")
    var speed = [0.1, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 4.0, 8.0, 16.0, 64.0, 1000.0]
    var buttons: Array<Button> = []

    override init(id: Int, controller: SceneController, bg: String) {
        super.init(id: id, controller: controller, bg: bg)

        indicatorArrow.position = CGPoint(x: 496, y: 589)
        addNode(node: indicatorArrow)

        let runRect = CGRect(x: 578, y: 740, width: 90, height: 30)
        let stopRect = CGRect(x: 578, y: 700, width: 90, height: 30)
        let resetRect = CGRect(x: 578, y: 660, width: 90, height: 30)
        let stepRect = CGRect(x: 578, y: 620, width: 90, height: 30)
        let upSpeed = CGRect(x: 480, y: 700, width: 90, height: 30)
        let downSpeed = CGRect(x: 480, y: 660, width: 90, height: 30)

        let runButton = Button(rect: runRect, text: "Start", scene: self, event: Event(delay: 0, id: 7, scene: self))
        let stopButton = Button(rect: stopRect, text: "Pause", scene: self, event: Event(delay: 0, id: 8, scene: self))
        let resetButton = Button(rect: resetRect, text: "Reset", scene: self, event: Event(delay: 0, id: 12, scene: self))
        let stepButton = Button(rect: stepRect, text: "Step", scene: self, event: Event(delay: 0, id: 9, scene: self))
        let upSpeedButton = Button(rect: upSpeed, text: "+ Speed", scene: self, event: Event(delay: 0, id: 10, scene: self))
        let downSpeedButton = Button(rect: downSpeed, text: "- Speed", scene: self, event: Event(delay: 0, id: 11, scene: self))

        buttons.append(runButton)
        buttons.append(stopButton)
        buttons.append(resetButton)
        buttons.append(stepButton)
        buttons.append(upSpeedButton)
        buttons.append(downSpeedButton)

        instructionPointerLabel.fontName = "AmericanTypewriter-Bold"
        instructionPointerLabel.fontSize = 20
        instructionPointerLabel.fontColor = SKColor.green
        instructionPointerLabel.position = CGPoint(x: 490, y: 620)
        addNode(node: instructionPointerLabel)

        speedLabel.fontName = "AmericanTypewriter-Bold"
        speedLabel.fontSize = 18
        speedLabel.fontColor = SKColor.green
        speedLabel.position = CGPoint(x: 490, y: 640)
        addNode(node: speedLabel)

        for i in 1...40 {
            let lineLabels = SKLabelNode()
            lineLabels.text = String(i)
            lineLabels.fontSize = 16
            lineLabels.fontName = "AmericanTypewriter-Bold"
            lineLabels.fontColor = SKColor.green
            let offset = Int(14.1 * Float(i - 1))
            lineLabels.position = CGPoint(x: 548, y: 583 - offset)
            lineLabels.zPosition = 10
            addNode(node: lineLabels)
        }
    }

    override func event(id: Int, data: Array<Int> = []) {
        switch id {
        case 5:
            //long supply chain for text input (part 4)
            parseCode(code: controller.codeIn)
            break
        case 6:
            //prevents alot of index out of range crashes
            if instructionArray.count > instructionPointer {

                //prepare data and execute instruction
                var toExe = instructionArray[instructionPointer]
                let instructionId = toExe.removeFirst()
                instruction(id: instructionId, data: toExe)

                if !halt {
                    //hook into next instruction if not halted
                    let start = Event(delay: 300, id: 6, scene: self)
                    controller.eventQ?.addEvent(event: start)
                }

                //increment instruction pointer by 1 if not a jump command
                if !(instructionId == 3 || instructionId == 4) {
                    instructionPointer += 1
                }
            }
        case 7:
            //start exec
            halt = false
            let start = Event(delay: 300, id: 6, scene: self)
            controller.eventQ?.addEvent(event: start)
            break
        case 8:
            //stop program execution
            halt = true
            break
        case 9:
            //step - exe one instruction, same as event 6 but no hook into next instruction
            if instructionArray.count > instructionPointer {

                var toExe = instructionArray[instructionPointer]
                let instructionId = toExe.removeFirst()
                instruction(id: instructionId, data: toExe)

                //increment instruction pointer by 1 if not a jump command
                if !(instructionId == 3 || instructionId == 4) {
                    instructionPointer += 1
                }
            }
        case 10:
            if currentSpeed < 11 {
                currentSpeed += 1
            }
            break
        case 11:
            if currentSpeed > 1 {
                currentSpeed -= 1
            }
        case 12:
            instructionPointer = 1
            break

        default:
            print("Control Unit Event Error")
        }
    }

    var lines: Array<String> = []

    //takes code, parses it and stores in the instruction array
    func parseCode(code: String) {

        //clear instruction array for a clean slate
        instructionArray = [[]]

        //each element of array is one line of code
        let codeLines = code.components(separatedBy: CharacterSet.newlines)

        for i in codeLines {

            //seperate each line into its componets as seperated by spaces
            var lineParts = i.components(separatedBy: CharacterSet.whitespaces)
            var instructionId = 0

            //decode keywords into ids
            switch(lineParts[0]) {
            case "load":
                instructionId = 1
                break
            case "add":
                instructionId = 2
                break
            case "jump":
                instructionId = 3
                break
            case "jumpif":
                instructionId = 4
                break
            case "sub":
                instructionId = 5
                break
            default:
                instructionId = -1
            }
            //taken any extra arguments and convert to ints and add on
            lineParts.removeFirst()

            //minimum arguments for instructions, 1 by default, 2 needed for jumpif and load
            let minimumArgs = instructionId == 1 || instructionId == 4 ? 2 : 1
            
            var instruction = lineParts.count >= minimumArgs ? [instructionId] : [-1]
            
            for i in lineParts {
                instruction.append(Int(i) ?? 0)
            }
            instructionArray.append(instruction)
        }
    }

    func instruction(id: Int, data: Array<Int>) {
        switch id {
        case 1:
            loadFromMemory(address: data[0], reg: data[1])
            break
        case 2:
            addToMemory(address: data[0])
            break
        case 3:
            //jump command
            instructionPointer = data[0]
            break
        case 4:
            //jump if command
            instructionPointer = zeroFlag ? data[0] : data[1]
            break
        case 5:
            //subtract command
            subtractToMemory(address: data[0])
            break
        default:
            print("Error Invalid Instruction ID: \(id)")
        }
    }

    func loadFromMemory(address: Int, reg: Int) {

        let memory = controller.memory!
        let alu = controller.alu!

        let setAdd = Event(delay: 0, id: 4, scene: memory, data: [address])
        let readMem = Event(delay: 500, id: 2, scene: memory, data: [1])
        let writeALU = Event(delay: 500, id: reg, scene: alu, data: [1])
        let writeALUo = Event(delay: 500, id: reg, scene: alu, data: [0])
        let readMemo = Event(delay: 500, id: 2, scene: memory, data: [0])

        controller.eventQ?.addEvent(event: setAdd)
        controller.eventQ?.addEvent(event: readMem)
        controller.eventQ?.addEvent(event: writeALU)
        controller.eventQ?.addEvent(event: writeALUo)
        controller.eventQ?.addEvent(event: readMemo)
    }

    func addToMemory(address: Int) {

        let memory = controller.memory!
        let alu = controller.alu!

        let setAdd = Event(delay: 0, id: 4, scene: memory, data: [address])
        let subALUo = Event(delay: 400, id: 5, scene: alu, data: [0])
        let readALU = Event(delay: 500, id: 3, scene: alu, data: [1])
        let writeMem = Event(delay: 500, id: 1, scene: memory, data: [1])
        let writeMemo = Event(delay: 500, id: 1, scene: memory, data: [0])
        let readALUo = Event(delay: 500, id: 3, scene: alu, data: [0])
        let remAdd = Event(delay: 500, id: 4, scene: memory, data: [0])

        controller.eventQ?.addEvent(event: setAdd)
        controller.eventQ?.addEvent(event: subALUo)
        controller.eventQ?.addEvent(event: readALU)
        controller.eventQ?.addEvent(event: writeMem)
        controller.eventQ?.addEvent(event: writeMemo)
        controller.eventQ?.addEvent(event: readALUo)
        controller.eventQ?.addEvent(event: remAdd)
    }

    func subtractToMemory(address: Int) {

        let memory = controller.memory!
        let alu = controller.alu!

        let setAdd = Event(delay: 0, id: 4, scene: memory, data: [address])
        let subALU = Event(delay: 400, id: 5, scene: alu, data: [1])
        let readALU = Event(delay: 400, id: 3, scene: alu, data: [1])
        let writeMem = Event(delay: 400, id: 1, scene: memory, data: [1])
        let writeMemo = Event(delay: 400, id: 1, scene: memory, data: [0])
        let readALUo = Event(delay: 400, id: 3, scene: alu, data: [0])
        let remAdd = Event(delay: 400, id: 4, scene: memory, data: [0])

        controller.eventQ?.addEvent(event: setAdd)
        controller.eventQ?.addEvent(event: subALU)
        controller.eventQ?.addEvent(event: readALU)
        controller.eventQ?.addEvent(event: writeMem)
        controller.eventQ?.addEvent(event: writeMemo)
        controller.eventQ?.addEvent(event: readALUo)
        controller.eventQ?.addEvent(event: remAdd)
    }

    override func mouseDown(point: CGPoint) {
        super.mouseDown(point: point)
        for i in buttons {
            i.update(point: point)
        }
    }
}


