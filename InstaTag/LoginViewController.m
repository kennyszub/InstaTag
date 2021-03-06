//
//  LoginViewController.m
//  InstaTag
//
//  Created by Ken Szubzda on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "LoginViewController.h"
#import "BrowseViewController.h"
#import "TagViewController.h"
#import <BoxContentSDK/BOXContentSDK.h>

@interface LoginViewController ()
@property (nonatomic, strong) UITabBarController *tabController;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITabBarController *tabController = [[UITabBarController alloc] init];
    
    BrowseViewController *bvc = [[BrowseViewController alloc] initWithClient:[BOXContentClient defaultClient]];
    TagViewController *tvc = [[TagViewController alloc] initWithClient:[BOXContentClient defaultClient]];
    
    bvc.tabBarItem.title = @"Browse";
    //    bvc.tabBarItem.image = [UIImage imageNamed:@"INSERTHERE"];
    bvc.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
    tvc.tabBarItem.title = @"Tag";
    tvc.tabBarItem.image = [UIImage imageNamed:@"priceTag"];
    
    tabController.viewControllers = @[bvc, tvc];
    self.tabController = tabController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLoginButton:(id)sender {
    //[BOXContentClient logOutAll];
    BOXContentClient *client = [BOXContentClient defaultClient];
    [client authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Login failed, please try again" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        } else {
            NSLog(@"Successful login");
            [self presentViewController:self.tabController animated:YES completion:nil];
        }
    } cancelBlock:nil];
}


@end
