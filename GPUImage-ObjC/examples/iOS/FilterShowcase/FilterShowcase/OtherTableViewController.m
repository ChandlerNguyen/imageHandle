//
//  OtherTableViewController.m
//  FilterShowcase
//
//  Created by wzkj on 2016/12/8.
//  Copyright © 2016年 Cell Phone. All rights reserved.
//

#import "OtherTableViewController.h"

#import "ColorTrackingViewController.h"
#import "DisplayViewController.h"
#import "FeatureExtractionViewController.h"
#import "MultiViewViewController.h"
#import "SimpleImageViewController.h"
#import "PhotoViewController.h"
#import "SimpleVideoFileFilterViewController.h"
#import "SimpleVideoFilterViewController.h"
#import "LMCamera.h"
#import "DoubleCameraViewController.h"

#import "FilterShowcase-Swift.h"

@interface OtherTableViewController ()
/**  列表 */
@property (nonatomic, strong) NSArray *viewControllers;
@end

@implementation OtherTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.viewControllers = @[@"ColorTracking",@"Cube",@"FeatureExtraction",@"MultiViewFilter",@"SimpleImageFilter",@"SimplePhotoFilter",@"SimpleVideoFileFilter",@"SimpleVideoFilter",@"LMCamera",@"LMCameraImage",@"DoubleCameraViewController",@"CIFilter"];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self.tabBarController tabBar] setHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self.tabBarController tabBar] setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.viewControllers objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{
            ColorTrackingViewController *colorTracking = [[ColorTrackingViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:colorTracking animated:YES];
            break;
        }
        case 1:{
            DisplayViewController *cube = [[DisplayViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:cube animated:YES];
            break;
        }
            
        case 2:{
            FeatureExtractionViewController *featureExtraction = [[FeatureExtractionViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:featureExtraction animated:YES];
            break;
        }
        case 3:{
            [self.navigationController pushViewController:[[MultiViewViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
            break;
        }
        case 4:{
            [self.navigationController pushViewController:[[SimpleImageViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
            break;
        }
        case 5:{
            [self.navigationController pushViewController:[[PhotoViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
            break;
        }
            
        case 6:{
            [self.navigationController pushViewController:[[SimpleVideoFileFilterViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
            break;
        }
        case 7:{
            [self.navigationController pushViewController:[[SimpleVideoFilterViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
            break;
        }
        case 8:
            [self.navigationController pushViewController:[[LMCamera alloc] initWithMediaTyp:LMMediaTypeVideo sessionPresset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack] animated:YES];
            break;
        case 9:{
            UIImage *image = [UIImage imageNamed:@"Lambeau.jpg"];
            [self.navigationController pushViewController:[[LMCamera alloc] initWithImage:image] animated:YES];
            break;
        }
        case 10:
            [self.navigationController pushViewController:[[DoubleCameraViewController alloc] init] animated:YES];
            break;
        case 11:
            [self.navigationController pushViewController:[[LMGLFilterImageController alloc] initWithNibName:nil bundle:nil] animated:YES];
            break;
        default:
            break;
    }
}

@end
