//
//  TagViewController.m
//  InstaTag
//
//  Created by Ken Szubzda on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "TagViewController.h"
#import <BoxContentSDK/BOXContentSDK.h>
#import "BOXMetadataInfoRequest.h"
#import "BOXMetadata.h"
#import "BOXMetadataCreateRequest.h"
#import "BOXMetadataUpdateRequest.h"
#import "CamFindClient.h"

@interface TagViewController () <BOXItemPickerDelegate>
@property (nonatomic, readwrite, strong) BOXContentClient *client;
@end

@implementation TagViewController

- (instancetype)initWithClient:(BOXContentClient *)client {
    self = [super init];
    if (self) {
        _client = client;
    }
    return self;
}

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
    
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    
    NSString *localFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.jpg"];
    NSURL *localURLPath = [[NSURL alloc] initFileURLWithPath:localFilePath];
    
    BOXFileDownloadRequest *boxRequest = [contentClient fileDownloadRequestWithID:file.modelID toLocalFilePath:localFilePath];
    [boxRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        // Update a progress bar, etc.
    } completion:^(NSError *error) {
        // Download has completed. If it failed, error will contain reason (e.g. network connection)
        if (error != nil) {
            NSLog(@"Error downloading: %@", error);
        } else {
            CamFindClient *camFind = [[CamFindClient alloc] init];
            [camFind imageRequestWithURL:localURLPath completion:^(NSString *token, NSError *error) {
                if (token != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableDictionary *fileInfo = [@{@"fileId" : file.modelID, @"token" : token, @"retry" : @"YES"} mutableCopy];
                        [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(getImageResponse:) userInfo:fileInfo repeats:NO];
                    });
                } else {
                    NSLog(@"Error: failed to get image token");
                }
            }];
        }
    }];
}

- (void)getImageResponse:(NSTimer *)timer {
    CamFindClient *camFind = [[CamFindClient alloc] init];
    NSMutableDictionary *fileInfo = timer.userInfo;
    [camFind imageResponseWithToken:fileInfo[@"token"] completion:^(NSString *keyWords, NSError *error) {
        if (keyWords != nil) {
            [self didGetFileWithFileId:fileInfo[@"fileId"] keyWords:keyWords];
        } else {
            if ([error.userInfo[@"reason"] isEqualToString:@"not completed"] && [fileInfo[@"retry"] isEqualToString:@"YES"]) {
                NSLog(@"retrying for reason: %@", error.userInfo[@"reason"]);
                // attempt one more time
                [fileInfo setObject:@"NO" forKey:@"retry"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getImageResponse:) userInfo:fileInfo repeats:NO];
                });
            } else {
                NSLog(@"Could not get keywords %@", error);
            }
        }
    }];
}

- (void)didGetFileWithFileId:(NSString *)fileId keyWords:(NSString *)keywords {
    NSLog(@"file Id %@", fileId);
    NSLog(@"keywords %@", keywords);
}


- (void)itemPickerController:(BOXItemPickerViewController *)controller didSelectBoxFolder:(BOXFolder *)folder {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
