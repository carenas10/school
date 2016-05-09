//
//  VTKCodecDetailViewController.m
//  jacksod.a4
//
//  Created by Jake Dawkins on 10/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import "VTKCodecDetailViewController.h"
#import "VTKEditSettingViewController.h"

@implementation VTKCodecDetailViewController

-(void)viewWillAppear:(BOOL)animated{
    
    _nameLabel.text = [NSString stringWithFormat:@"%@",_detailSetting.name];
    
    _idLabel.text = [NSString stringWithFormat:@"ID: %d",_detailSetting.setting_ID];

    _resolutionLabel.text = [NSString stringWithFormat:@"Resolution: %@",_detailSetting.resolution];
    
    _bitrateLabel.text = [NSString stringWithFormat:@"Bitrate (kbps): %d",_detailSetting.bitrate];
    _framerateLabel.text = [NSString stringWithFormat:@"Framerate (drop): %d",_detailSetting.framerate];
    
    //follow foreign keys
    _videoCodecLabel.text = [NSString stringWithFormat:@"Video Codec: %@",[[Database database] videoCodecWithID:_detailSetting.vidCodec+1].codecName];
    _audioCodecLabel.text = [NSString stringWithFormat:@"Audio Codec: %@",[[Database database] audioCodecWithID:_detailSetting.audioCodec+1].codecName];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"editSetting"]){
        VTKEditSettingViewController *destination = [segue destinationViewController];
        destination.settingToEdit =_detailSetting;
    }
}




- (IBAction)deleteSetting:(id)sender {
    if([[Database database] removeSetting:_detailSetting.setting_ID]){
        [self.navigationController popViewControllerAnimated:YES];
        UIAlertView *settingRemovedAlert = [[UIAlertView alloc]initWithTitle:@"Setting Removed!"
                                                                   message:@"Your setting has been removed. Pull down to refresh."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Okay"
                                                         otherButtonTitles:nil];
        [settingRemovedAlert show];
    }
}

@end