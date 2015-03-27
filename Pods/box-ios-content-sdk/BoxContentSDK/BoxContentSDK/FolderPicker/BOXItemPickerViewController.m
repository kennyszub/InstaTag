//
//  BOXItemPickerViewController.m
//  BoxContentSDK
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//

#import "BOXContentSDK.h"

#import "BOXItemPickerTableViewCell.h"
#import "UIImage+BOXAdditions.h"
#import "NSString+BOXAdditions.h"
#import "BOXItemPickerViewController.h"
#import "BOXItem+BOXAdditions.h"

#define kStretchHeightOffset 16.0
#define kButtonWidth 100
#define kStretchNavBarHeight 20.0
#define kCellHeight 58.0

@interface BOXItemPickerViewController ()

@property (nonatomic, readwrite, strong) BOXContentClient *client;

@property (nonatomic, readwrite, strong) NSString *folderID;
@property (nonatomic, readwrite, strong) BOXFolder *folder;

@property (nonatomic, readwrite, assign) NSUInteger totalCount;
@property (nonatomic, readwrite, assign) NSUInteger currentPage;
@property (nonatomic, readwrite, strong) NSMutableArray *items;

@property (nonatomic, readwrite, strong) UIBarButtonItem *selectItem;
@property (nonatomic, readwrite, strong) UIBarButtonItem *closeItem;
@property (nonatomic, readwrite, strong) UIView *tableHeaderView;

@property (nonatomic, readwrite, strong) NSString *thumbnailPath;
@property (nonatomic, readwrite, assign) BOOL thumbnailsEnabled;

@property (nonatomic, readwrite, strong) BOXItemPickerHelper *helper;

@property (nonatomic, readwrite, assign) BOOL isAuthorizationControllerShown;

@end

@implementation BOXItemPickerViewController


- (id)initWithClient:(BOXContentClient *)client rootFolderID:(NSString *)rootFolderID thumbnailsEnabled:(BOOL)thumbnailsEnabled cachedThumbnailsPath:(NSString *)cachedThumbnailsPath selectableObjectType:(BOXItemPickerObjectType)selectableObjectType
{
    self = [super init];
    if (self != nil)
    {
        _folderID = rootFolderID;
        _items = [NSMutableArray array];
        _numberOfItemsPerPage = 100;

        _thumbnailPath = cachedThumbnailsPath;
        _thumbnailsEnabled = thumbnailsEnabled;
        _selectableObjectType = selectableObjectType;

        _client = client;
        _helper = [[BOXItemPickerHelper alloc] initWithClient:client];
    }
    return self;
}

#pragma mark - Bar Buton Items

- (UIBarButtonItem *)closeItem
{
    if (_closeItem == nil) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Title : button closing the folder picker") style:UIBarButtonItemStylePlain target:self action:@selector(closeTouched:)];
        [_closeItem setTitlePositionAdjustment:UIOffsetMake(0.0, 1) forBarMetrics:UIBarMetricsDefault];
    }

    return _closeItem;
}

- (UIBarButtonItem *)selectItem
{
    if (!_selectItem) {
        _selectItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", @"Title : button allowing the user to pick the current folder") style:UIBarButtonItemStyleDone target:self action:@selector(selectTouched:)];
        _selectItem.width = kButtonWidth;
    }

    return _selectItem;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Creating the cache folder if needed
    if (self.thumbnailPath != nil) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.thumbnailPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.thumbnailPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                BOXLog(@"Cannot create Folder picker's cache folder : %@", error);
            }
        }
    }

    // UI Setup
    self.tableView.rowHeight = kCellHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableHeaderView = [[UIView alloc] init];
    self.tableHeaderView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], NSForegroundColorAttributeName,
      [[NSShadow alloc] init], NSShadowAttributeName,
      [UIFont boldSystemFontOfSize:16.0], NSFontAttributeName,
      nil]];
    
    // Back button
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Title : cell allowing the user to go back in the viewControllers tree") style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    
    self.navigationItem.rightBarButtonItem = self.closeItem;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar" inBoxSDKResourcesBundle:[BOXContentClient resourcesBundle]] resizableImageWithCapInsets:UIEdgeInsetsMake(kStretchNavBarHeight, 1.0, kStretchNavBarHeight, 1.0)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateFolderPicker];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.helper purgeInMemoryCache];
    [self.helper cancelThumbnailOperations];
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableHeaderView.frame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 1.0);
}

#pragma mark - Data management

- (void)populateFolderPicker
{
    BOXFolderRequest *request = [self.client folderInfoRequestWithID:self.folderID];
    [request performRequestWithCompletion:^(BOXFolder *folder, NSError *error) {
        if (error) {
            if (error.code == BOXContentSDKOAuth2ErrorAccessTokenExpiredOperationWillBeClonedAndReenqueued)
            {
                // This error code indicates that an access token is expired but the SDK is attempting to refresh
                // tokens and retry the API call.
                //
                // If the tokens cannot be refreshed, this block will be invoked again and the next if-condition
                // will be hit.
                return;
            }
            
            // If any of these error code are returned, the user has to login.
            if (error.code == BOXContentSDKOAuth2ErrorAccessTokenExpiredOperationCouldNotBeCompleted || error.code == BOXContentSDKOAuth2ErrorAccessTokenExpiredOperationCannotBeReenqueued) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self boxAuthenticationFailed:nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationItem.prompt = NSLocalizedString(@"An error occured while retrieving data", @"Descriptive : Prompt explaining that an error occured during an API call") ;
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Toolbar Setup
                UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                self.toolbarItems = @[space, self.selectItem];
                if (self.selectableObjectType != BOXItemPickerObjectTypeFile)
                {
                    [self.navigationController setToolbarHidden:NO];
                    [self.navigationController.toolbar setBackgroundImage:[[UIImage imageNamed:@"footer" inBoxSDKResourcesBundle:[BOXContentClient resourcesBundle]] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0)] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
                    [self.navigationController.toolbar setBackgroundImage:[[UIImage imageNamed:@"footer" inBoxSDKResourcesBundle:[BOXContentClient resourcesBundle]] resizableImageWithCapInsets:UIEdgeInsetsMake(kStretchHeightOffset, 1.0, kStretchHeightOffset, 1.0)] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
                }
                self.title = folder.name;
                self.folder = folder;
                self.navigationItem.prompt = nil;
                
                if ([self respondsToSelector:@selector(refreshControl)]) {
                    self.refreshControl = [[UIRefreshControl alloc] init];
                    [self.refreshControl addTarget:self
                                            action:@selector(refreshData)
                                  forControlEvents:UIControlEventValueChanged];
                }
            });
        }
    }];
    
    [self refreshData];
}

- (void)refreshData
{
    // Remove existing items array when refreshing
    [self loadItemsWithItemReplacement:YES];
}

- (void)loadItemsWithItemReplacement:(BOOL)replaceItems
{
    BOOL supportsRefreshControl = [self respondsToSelector:@selector(refreshControl)];
    if (supportsRefreshControl)
    {
        [self.refreshControl beginRefreshing];
    }
    
    BOXPaginatedItemArrayRequest *request = [self.client folderItemsRequestWithID:self.folderID inRange:NSMakeRange(self.currentPage * self.numberOfItemsPerPage, self.numberOfItemsPerPage)];
    request.requestAllItemFields = YES;
    [request performRequestWithCompletion:^(NSArray *items, NSUInteger totalCount, NSRange range, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (supportsRefreshControl)
                {
                    [self.refreshControl endRefreshing];
                }
                // If any of these error code are returned, the user has to login.
                if (error.code == BOXContentSDKOAuth2ErrorAccessTokenExpiredOperationCouldNotBeCompleted || error.code == BOXContentSDKOAuth2ErrorAccessTokenExpiredOperationCannotBeReenqueued)
                {
                    [self boxAuthenticationFailed:nil];
                }
                else {
                    self.navigationController.navigationBar.tintColor = [UIColor redColor];
                    self.navigationItem.prompt = NSLocalizedString(@"An error occured while retrieving data", @"Descriptive : Prompt explaining that an error occured during an API call") ;
                }
            });
        } else {
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            
            if (replaceItems) {
                self.items = [NSMutableArray array];
            }
            
            for (BOXItem *item in items) {
                [self.items addObject:item];
            }
            
            self.totalCount = totalCount;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (supportsRefreshControl)
                {
                    [self.refreshControl endRefreshing];
                }
                self.navigationItem.prompt = nil;
                [self.tableView reloadData];
            });
        }
    }];
}

#pragma mark - Callbacks

- (void)closeTouched:(id)sender
{
    [self.delegate itemPickerControllerDidCancel:self];
}

- (void)selectTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(itemPickerController:didSelectBoxFolder:)]) {
        [self.delegate itemPickerController:self didSelectBoxFolder:self.folder];
    }
}

- (NSUInteger)currentNumberOfItems
{
    return [self.items count];
}

- (BOXItem *)itemAtIndex:(NSUInteger)index
{
    return [self.items objectAtIndex:index];
}

- (void)loadNextSetOfItems
{
    self.currentPage++;
    [self loadItemsWithItemReplacement:NO];
}

#pragma mark - Cache

- (void)purgeCache
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.thumbnailPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.thumbnailPath error:nil];
    }
}

- (void)boxAuthenticationFailed:(NSNotification *)notification
{
    // This method can be called twice when a folder picker loads : when the get item info fails and when the get folder children fails
    if (!self.isAuthorizationControllerShown) {
        self.isAuthorizationControllerShown = YES;
        [self.client authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
            [self refreshData];
            self.isAuthorizationControllerShown = NO;
        } cancelBlock:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = [self currentNumberOfItems];
    NSUInteger total = self.totalCount;
    
    // +1 for the "load more" cell at the bottom.
    return (count < total) ? count + 1 : count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BOXCell";
    static NSString *FooterIdentifier = @"BOXFooterCell";
    
    UITableViewCell *returnCell = nil;
    
    if (indexPath.row < [self currentNumberOfItems]) {
        BOXItemPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[BOXItemPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        }
        
        BOXItem *item = [self itemAtIndex:indexPath.row];
        
        if (self.selectableObjectType == BOXItemPickerObjectTypeFolder && ![item isKindOfClass:[BOXFolder class]]) {
            cell.enabled = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.enabled = YES;
        }
        
        cell.textLabel.text = item.name;
        NSString * desc = [NSString stringWithFormat:NSLocalizedString(@"%@ - Last update : %@", @"Title: File size and last modified timestamp (example: 5MB - Last Update : 2013-09-06 03:55)"), [NSString box_humanReadableStringForByteSize:item.size], [self.helper dateStringForItem:item]];
        cell.detailTextLabel.text = desc;
        cell.imageView.image = [[item icon] imageWith2XScaleIfRetina];
        
        cell.helper = self.helper;
        cell.cachePath = self.thumbnailPath;
        cell.showThumbnails = self.thumbnailsEnabled;
        cell.item = item;
        
        if (!cell.enabled) {
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        } else {
            cell.textLabel.textColor = [UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
        }
        returnCell = cell;
    } else {
        UITableViewCell *footerCell = [tableView dequeueReusableCellWithIdentifier:FooterIdentifier];
        if (!footerCell) {
            footerCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FooterIdentifier];
            footerCell.textLabel.textColor = [UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0];
        }
        footerCell.textLabel.text =  NSLocalizedString(@"Load more files ...", @"Title : Cell allowing the user to load the next page of items");
        footerCell.imageView.image = nil;
        footerCell.detailTextLabel.text = nil;
        
        returnCell = footerCell;
    }
    
    return returnCell;
}

#pragma mark - TableView Delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self currentNumberOfItems]) {
        BOXItemPickerTableViewCell *cell = (BOXItemPickerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        return (cell.enabled) ? indexPath : nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self currentNumberOfItems]) {
        BOXItem *item = (BOXItem *)[self itemAtIndex:indexPath.row];
        
        if ([item isKindOfClass:[BOXFolder class]]) {
            BOXItemPickerViewController *childFolderPicker = [[BOXItemPickerViewController alloc] initWithClient:self.client
                                                                                                 rootFolderID:item.modelID
                                                                                            thumbnailsEnabled:self.thumbnailsEnabled
                                                                                         cachedThumbnailsPath:self.thumbnailPath
                                                                                         selectableObjectType:self.selectableObjectType];
            [self.navigationController pushViewController:childFolderPicker animated:YES];
        } else if ([item isKindOfClass:[BOXFile class]]) {
            if ([self.delegate respondsToSelector:@selector(itemPickerController:didSelectBoxFile:)]) {
                [self.delegate itemPickerController:self didSelectBoxFile:(BOXFile *)item];
            }
        }
    } else {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO animated:YES];
        [self loadNextSetOfItems];
    }
}

@end
