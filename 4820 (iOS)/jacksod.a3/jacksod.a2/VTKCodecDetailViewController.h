//
//  VTKCodecDetailViewController.h
//  jacksod.a2
//
//  Created by Jake Dawkins on 10/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "database.h"
#import <UIKit/UIKit.h>
#import "database.h"

@interface VTKCodecDetailViewController:UIViewController

@property (strong,nonatomic) VidSetting *detailSetting;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *framerateLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoCodecLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioCodecLabel;





@end