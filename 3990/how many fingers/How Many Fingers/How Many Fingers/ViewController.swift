//
//  ViewController.swift
//  How Many Fingers
//
//  Created by Jake Dawkins on 9/19/15.
//  Copyright © 2015 Jake Dawkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var guess: UITextField!
    
    @IBAction func guessButton(sender: AnyObject) {
        let randomNumber = arc4random_uniform(6)
        let guessInt = Int(guess.text!)
        
        if guessInt != nil {
            if Int(randomNumber) == guessInt {
                resultLabel.text = "Correct"
            } else {
                resultLabel.text = "Nope. It was \(randomNumber)"
            }
        } else {
            resultLabel.text = "Please Enter a Number"
        }
        
        
        print(guess.text)
        
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


}

