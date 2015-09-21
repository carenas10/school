//
//  ViewController.swift
//  Is It Prime
//
//  Created by Jake Dawkins on 9/19/15.
//  Copyright © 2015 Jake Dawkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var entryField: UITextField!
    @IBAction func testButton(sender: AnyObject) {
        let testInt = Int(entryField.text!)
        let result: Bool = isItPrime(testInt!)
        
        if result {
            resultLabel.text = "It is prime!"
        }
        else {
            resultLabel.text = "Not Prime"
        }
    }
    @IBOutlet weak var resultLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func isItPrime(test:Int) -> Bool {
        var i : Int = 3 //tester
        if test % 2 == 0 {return false} //even number
        while i < test / 2 + 1 {
            if test % i == 0 {
                return false
            }
            i = i + 2 //skip all evens
        }
        return true
    }


}

