//
//  ViewController.m
//  OCThumborExample
//
//  Created by Daniel Heckrath on 08.03.14.
//  Copyright (c) 2014 Codeserv. All rights reserved.
//

#import "ViewController.h"

#import <OCThumbor/OCThumbor.h>

@interface ViewController ()

@property (nonatomic, strong) OCThumbor *thumbor;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.thumbor = [OCThumbor createWithHost:@"http://stormy-stone-5336.herokuapp.com/" key: @"DasIstMeinSecretKey"];
    
    OCThumborURLBuilder *builder = [self.thumbor buildImage:@"http://s.glbimg.com/jo/g1/f/original/2012/03/16/supersonic-skydiver_fran.jpg"];
    
    [builder resizeWidth:300 height:200];
    NSString *imageUrl = [builder toUrl];
    
    NSLog(@"%@", imageUrl);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
