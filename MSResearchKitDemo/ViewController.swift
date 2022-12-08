//
//  ViewController.swift
//  MSResearchKitDemo
//
//  Created by Eric Lightfoot on 2022-12-06.
//

import UIKit
import ResearchKit
import os.log

class SimpleTaskViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let myStep = ORKInstructionStep(identifier: "intro")
        myStep.title = "Welcome to ResearchKit"
        
        let task = ORKOrderedTask(identifier: "task", steps: [myStep])
        
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }


}

extension SimpleTaskViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController,
                    didFinishWith reason: ORKTaskViewControllerFinishReason,
                                        error: Error?) {
        let _ = taskViewController.result
        // You could do something with the result here.
        
        // Then, dismiss the task view controller(s).
        dismiss(animated: true, completion: nil)
    }
}
