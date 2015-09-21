//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

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