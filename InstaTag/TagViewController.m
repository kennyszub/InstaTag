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
    BOXContentClient *client = [BOXContentClient defaultClient];
    BOXItemPickerViewController *itemPickerController = [[BOXItemPickerViewController alloc] initWithClient:client rootFolderID:@"0" thumbnailsEnabled:YES cachedThumbnailsPath:nil selectableObjectType:BOXItemPickerObjectTypeFileAndFolder];
    itemPickerController.delegate = self;

    BOXItemPickerNavigationController *navController = [[BOXItemPickerNavigationController alloc] initWithRootViewController:itemPickerController];
    [self presentViewController:navController animated:YES completion:nil];
    
}

#pragma mark file picker delegate methods
- (void)itemPickerControllerDidCancel:(BOXItemPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)itemPickerController:(BOXItemPickerViewController *)controller didSelectBoxFile:(BOXFile *)file {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)itemPickerController:(BOXItemPickerViewController *)controller didSelectBoxFolder:(BOXFolder *)folder {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
