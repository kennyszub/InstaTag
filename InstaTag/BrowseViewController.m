//
//  BrowseViewController.m
//  InstaTag
//
//  Created by Ken Szubzda on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "BrowseViewController.h"
#import "BOXMetadataCreateRequest.h"
#import "BOXMetadataUpdateRequest.h"
#import "BOXMetadataInfoRequest.h"
#import "BOXMetadata.h"
#import "BOXContentClient.h"
#import <BoxContentSDK/BOXContentSDK.h>
#import "BrowseCollectionViewCell.h"
#import "BOXSampleThumbnailsHelper.h"
#import "MetadataViewController.h"
#import <SVProgressHUD.h>

@interface BrowseViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
@property (nonatomic, readwrite, strong) BOXContentClient *client;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *files;
@property (strong, nonatomic) NSMutableArray *allFiles;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@end

@implementation BrowseViewController

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
    self.files = [NSMutableArray array];
    BOXPaginatedItemArrayRequest *itemsRequest = [self.client folderItemsRequestWithID:@"0" inRange:NSMakeRange(0,1000)];
    itemsRequest.requestAllItemFields = YES;
    
    [itemsRequest performRequestWithCompletion:^(NSArray *items, NSUInteger totalCount, NSRange range, NSError *error) {
        for (BOXItem *item in items) {
            if ([item.type isEqualToString:BOXAPIItemTypeFile] && [[BOXSampleThumbnailsHelper sharedInstance] shouldDownloadThumbnailForItemWithName:item.name]) {
                [self.files addObject:item];
            }
        }
        self.allFiles = [self.files copy];
        [self.collectionView reloadData];
    }];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"BrowseCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BrowseCollectionViewCell"];
    
    self.searchBar.delegate = self;
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
}

#pragma mark - Search bar methods

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.view addGestureRecognizer:self.tapRecognizer];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.view removeGestureRecognizer:self.tapRecognizer];
    if ([searchBar.text isEqualToString:@""]) {
        self.files = [self.allFiles copy];
        [self.collectionView reloadData];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    BOXSearchRequest *request = [self.client searchRequestWithQuery:self.searchBar.text inRange:NSMakeRange(0,100)];
    [SVProgressHUD show];
    [self.client prepareRequest:request];
    [request performRequestWithCompletion:^(NSArray *items, NSUInteger totalCount, NSRange range, NSError *error) {
        self.files = [NSMutableArray array];
        [SVProgressHUD dismiss];
        if (error == nil) {
            for (BOXItem *item in items) {
                if ([item.type isEqualToString:BOXAPIItemTypeFile] && [[BOXSampleThumbnailsHelper sharedInstance] shouldDownloadThumbnailForItemWithName:item.name]) {
                    [self.files addObject:item];
                }
            }
            [self.collectionView reloadData];
        }
    }];
    [self.searchBar endEditing:YES];
    [self.view removeGestureRecognizer:self.tapRecognizer];
}

- (void)onTap {
    [self.searchBar endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    // We want to get all the fields for our file. Not setting this property to YES will result in the API returning only the default fields.
//    NSLog(@"attempt metadata");
//    BOXMetadataInfoRequest *request = [[BOXMetadataInfoRequest alloc] initWithFileID:@"5009158865"];
//    [self.client prepareRequest:request];
//    [request performRequestWithCompletion:^(BOXMetadata *metadata, NSError *error) {
//        if (error == nil) {
//            NSLog(@"%@", metadata.properties);
//        } else {
//            NSLog(@"error %@", error.description);
//        }
//    }];
    
    //    BOXMetadataCreateRequest *createRequest = [[BOXMetadataCreateRequest alloc] initWithFileID:@"5009010993" properties:@"customers"];
    //    [self.client prepareRequest:createRequest];
    //
    //    [createRequest performRequestWithCompletion:^(BOXMetadata *metadata, NSError *error) {
    //        if (error == nil) {
    //            NSLog(@"%@", metadata.properties);
    //        } else {
    //            NSLog(@"error %@", error.description);
    //        }
    //    }];
//    
//    BOXMetadataUpdateRequest *updaterequest = [[BOXMetadataUpdateRequest alloc] initWithFileID:@"5009158865" properties:@"insurance3"];
//    [self.client prepareRequest:updaterequest];
//    [updaterequest performRequestWithCompletion:^(BOXMetadata *metadata, NSError *error) {
//        if (error == nil) {
//            NSLog(@"%@", metadata.properties);
//        } else {
//            NSLog(@"error %@", error.description);
//        }
//    }];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.files.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BrowseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BrowseCollectionViewCell" forIndexPath:indexPath];
    cell.file = (BOXFile *)self.files[indexPath.row];
    cell.client = self.client;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MetadataViewController *vc = [[MetadataViewController alloc] initWithClient:self.client files:self.files startingIndex:indexPath.row];
    [self presentViewController:vc animated:YES completion:nil];
    //[self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
