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
#import "SVProgressHUD.h"

@interface TagViewController () <BOXItemPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, readwrite, strong) BOXContentClient *client;
@property (weak, nonatomic) IBOutlet UIView *notifView;
@property (weak, nonatomic) IBOutlet UILabel *notifTextLabel;

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

- (void)viewDidAppear:(BOOL)animated {
    self.notifView.hidden = YES;
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
- (IBAction)onTakePictureButton:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"temp2.png"];
    NSURL *localURLPath = [[NSURL alloc] initFileURLWithPath:path];

    NSData* data = UIImagePNGRepresentation(editedImage);
    [data writeToFile:path atomically:YES];
    
    
    
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    NSString *localFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:path];
    BOXFileUploadRequest *uploadRequest = [contentClient fileUploadRequestToFolderWithID:@"0" fromLocalFilePath:localFilePath];
    [SVProgressHUD show];

    [uploadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        // Update a progress bar, etc.
    } completion:^(BOXFile *file, NSError *error) {
        // Upload has completed. If successful, file will be non-nil; otherwise, error will be non-nil.
        if (error != nil) {
            NSLog(@"Error downloading: %@", error);
        } else {
            CamFindClient *camFind = [[CamFindClient alloc] init];
            [camFind imageRequestWithURL:localURLPath completion:^(NSString *token, NSError *error) {
                if (token != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableDictionary *fileInfo = [@{@"fileId" : file.modelID, @"token" : token, @"retry" : @"YES"} mutableCopy];
                        [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(getImageResponse:) userInfo:fileInfo repeats:NO];
                    });
                } else {
                    NSLog(@"Error: failed to get image token");
                }
            }];
        }
    }];
    
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
    [SVProgressHUD show];
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
                        [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(getImageResponse:) userInfo:fileInfo repeats:NO];
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
                    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getImageResponse:) userInfo:fileInfo repeats:NO];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showNotificationViewWithString:@"failed to get keywords"];
                });
            }
        }
    }];
}

- (void)didGetFileWithFileId:(NSString *)fileId keyWords:(NSString *)keywords {
    BOXMetadataCreateRequest *createRequest = [[BOXMetadataCreateRequest alloc] initWithFileID:fileId properties:keywords];
    [self.client prepareRequest:createRequest];
    
    [createRequest performRequestWithCompletion:^(BOXMetadata *metadata, NSError *error) {
        if (error == nil) {
            NSLog(@"%@", metadata.properties);
        } else {
            NSLog(@"error %@", error.description);
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showNotificationViewWithString:keywords];
    });
}

- (void)showNotificationViewWithString:(NSString *)keywords{
    [SVProgressHUD dismiss];

    self.notifView.alpha = 1;
    self.notifView.hidden = NO;
    self.notifTextLabel.text = [NSString stringWithFormat:@"Photo tagged with metadata: %@", keywords];

    [self performSelector:@selector(hideNotificationView) withObject:nil afterDelay:4];
}

- (void)hideNotificationView {
    [UIView animateWithDuration:1.3 animations:^{
        self.notifView.alpha = 0;
    } completion:^(BOOL finished) {
        self.notifView.hidden = YES;
    }];
}


- (void)itemPickerController:(BOXItemPickerViewController *)controller didSelectBoxFolder:(BOXFolder *)folder {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
