//
//  TestTableViewController.m
//  UIImageOperationDemo
//
//  Created by 高磊 on 2017/4/20.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "TestTableViewController.h"
#import "GIFViewController.h"
#import "UIImageSimpleViewController.h"
#import "AddTitleOrImageViewController.h"
#import "WipeViewController.h"
#import "SnapViewController.h"

@interface TestTableViewController ()

@property (nonatomic,strong) NSArray *datas;

@end

@implementation TestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.title = @"UIImage处理";
    self.datas = [NSArray arrayWithObjects:@"简单图片处理",@"GIF图片展示",@"图片添加文字或者图片",@"图片截屏",@"图片擦除", nil];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"testCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.datas[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            UIImageSimpleViewController *simpleVc = [[UIImageSimpleViewController alloc] init];
            [self.navigationController pushViewController:simpleVc animated:YES];
        }
            break;
        case 1:
        {
            GIFViewController *gifVc = [[GIFViewController alloc] init];
            [self.navigationController pushViewController:gifVc animated:YES];
        }
            break;
        case 2:
        {
            AddTitleOrImageViewController *addVc = [[AddTitleOrImageViewController alloc] init];
            [self.navigationController pushViewController:addVc animated:YES];
        }
            break;
        case 3:
        {
            SnapViewController *snapVc = [[SnapViewController alloc] init];
            [self.navigationController pushViewController:snapVc animated:YES];
        }
            break;

        case 4:
        {
            WipeViewController *wipeVc = [[WipeViewController alloc] init];
            [self.navigationController pushViewController:wipeVc animated:YES];
        }
            break;

        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
