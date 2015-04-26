//
//  SwagLevel.m
//  Swag O'Meter
//
//  Created by Jake Dawkins on 9/5/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import "SwagLevel.h"
#import "foundation/foundation.h"

@implementation SwagLevel

+(NSMutableArray *)getLetterPairs:(NSString *)inputString
{
    int pairs = [inputString length];
    NSMutableArray *pairsArray = [[NSMutableArray alloc]initWithCapacity:pairs];
    for (int i=0; i<pairs-1; i++){
        [pairsArray addObject:[inputString substringWithRange:NSMakeRange(i,2)]]; //add pair string to array
    }
    return pairsArray;
}//getLetterPairs

+(NSMutableArray *)getWordLetterPairs:(NSString *)inputString
{
    NSMutableArray *allPairs = [[NSMutableArray alloc]init];
    
    //split input string into words
    NSArray *words = [inputString componentsSeparatedByString: @" "];
    
    //for each word
    for (int w=0; w<words.count; w++){
        [allPairs addObjectsFromArray:[SwagLevel getLetterPairs:words[w]]];
    }
    
    return allPairs;
}//getWordLetterPairs

+(NSNumber *)getSwagLevel:(NSString *)name{
    //NSString *swagNames = @"chris brown kanye west rihanna big sean";
    NSArray *swagNamesArray = @[@"chris brown",@"kanye west" ,@"rihanna",@"big sean",@"beyonce",@"jayz",@"tony stark",@"george lucas",@"dr dre",@"matt damon",@"lebron james",@"robert downey jr",@"warren buffett",@"kevin hart",@"aziz ansari",@"tim cook",@"steve jobs",@"simon cowell",@"justin timberlake",@"stephen colbert",@"queen elizabeth",@"barack obama",@"scarlett johansson"];
    
    int highestIntesection = -1;
    int intersection = -1;
    int arrayUnion = 0; //= [swagNames length]+[name length];
    
    //convert to lower case & build pair arrays
    NSMutableArray *pairs1; //level pairs of swag people
    NSMutableArray *pairs2; //letter pairs of input name

    //run test for each name, pick score of highest match.
    for (int n=0; n<[swagNamesArray count];n++){
        
        //convert to lower case & build pair arrays
        pairs1 = [SwagLevel getWordLetterPairs:[swagNamesArray[n] lowercaseString]];
        pairs2 = [SwagLevel getWordLetterPairs:[name lowercaseString]];
        intersection = 0;

        //count intersections.
        for (int i=0; i<[pairs1 count]; i++){
            for (int j=0; j<[pairs2 count]; j++){
                if ([pairs1[i] isEqualToString:pairs2[j]]){
                    intersection++;
                    [pairs2 removeObjectAtIndex:j];
                    break;
                }//if
            }//for j
        }//for i

        if (intersection > highestIntesection){
            highestIntesection = intersection;
            arrayUnion = [swagNamesArray[n] length]+[name length];
            //arrayUnion = [pairs1 count] + [pairs2 count];
        }
        
    }//for words
    
    NSLog([NSString stringWithFormat:@"%d",arrayUnion]);
    
    return ([NSNumber numberWithFloat:(2.0*highestIntesection)/arrayUnion]);
    
}//getSwagLevel

@end
