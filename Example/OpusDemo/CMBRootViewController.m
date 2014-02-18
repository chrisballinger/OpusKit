//
//  CMBRootViewController.m
//  OpusDemo
//
//  Created by Christopher Ballinger on 2/16/14.
//
//

#import "CMBRootViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CMBRootViewController ()

@end

@implementation CMBRootViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.audioController = [[CMBAudioController alloc] init];
        
        

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
