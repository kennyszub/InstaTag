//
//  MetadataViewController.m
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "MetadataViewController.h"
#import "DetailsCustomView.h"

@interface MetadataViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readwrite, strong) BOXContentClient *client;
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, assign) NSInteger startingIndex;
@end

@implementation MetadataViewController

- (instancetype)initWithClient:(BOXContentClient *)client files:(NSArray *)files startingIndex:(NSInteger) startingIndex; {
    self = [super init];
    if (self) {
        _client = client;
        _files = files;
        _startingIndex = startingIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    for (int i = 0; i < self.files.count; i++) {
        CGFloat xOrigin = i *self.view.frame.size.width;
        DetailsCustomView *detailsView = [[DetailsCustomView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        
        detailsView.client = self.client;
        detailsView.file = self.files[i];
        [self.scrollView addSubview:detailsView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIView *subview = self.scrollView.subviews[i];
        CGFloat xOrigin = i *self.view.frame.size.width;
        [subview setFrame:CGRectMake(xOrigin, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    }
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*self.startingIndex, 0)];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.files.count, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
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
