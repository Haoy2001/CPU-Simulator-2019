//
//  Scene.swift
//  CPU Simulator 2019
//
//  Created by Hao Yun on 2018-01-09.
//  Copyright © 2018 Hao Yun. All rights reserved.
//

import Foundation
import SpriteKit

class Scene {

    var id: Int
    var stage: SKScene
    var controller: SceneController
    var nodeArray: Array<SKNode>
    var background: SKSpriteNode
    var back = SKShapeNode(rect: CGRect(x: 50, y: 700, width: 100, height: 100))

    init(id: Int, controller: SceneController, bg: String) {

        self.id = id
        self.controller = controller
        stage = controller

        //array for storing all objects in a given scene
        //needed in order to be able to hide/show on command
        nodeArray = []

        //setup background
        background = SKSpriteNode(imageNamed: bg)
        background.size = CGSize(width: stage.size.width, height: stage.size.height)
        background.zPosition = -99
        background.position = CGPoint(x: stage.size.width / 2, y: stage.size.height / 2)
        addNode(node: background)
        addNode(node: back)
    }

    //called when scene is active to update scene
    func update(_ currentTime: TimeInterval) { }

    //called when it is time for scene to display or do something
    func event(id: Int, data:Array<Int> = []) { }

    //mouse input
    func mouseDown(event: NSEvent) {
        if back.contains(CGPoint(x: event.locationInWindow.x, y: event.locationInWindow.y)) {
            controller.changeScene(id: 0)
        }
    }


    //add spritekit node to scene, also added to reference array for future use
    func addNode(node: SKNode) {
        nodeArray.append(node)
        stage.addChild(node)
    }

    //display scene
    func show() {
        for i in nodeArray {
            i.isHidden = false
        }
    }

    //hide scene
    func hide() {
        for i in nodeArray {
            i.isHidden = true
        }
    }

}
