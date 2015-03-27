//
//  TagViewController.m
//  InstaTag
//
//  Created by Ken Szubzda on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "TagViewController.h"
#import <BoxContentSDK/BOXContentSDK.h>


@interface TagViewController () <BOXItemPickerDelegate>

@end

@implementation TagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTagBoxFolderButton:(id)sender {
    BOXItemPickerViewController *itemPickerController = [[BOXItemPickerViewController alloc] init];
    itemPickerController.delegate = self;
    [self presentViewController:itemPickerController animated:YES completion:nil];
    
}

#pragma mark file picker delegate methods
- (void)itemPickerControllerDidCancel:(BOXItemPickerViewController *)controller {
    NSLog(@"cancel");
}


@end
