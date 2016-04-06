//
//  QYLoginViewController.m
//  QYLeanCloudDemo
//
//  Created by 云菲 on 3/31/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYLoginViewController.h"

@interface QYLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *selfIDTf;
@property (weak, nonatomic) IBOutlet UITextField *friendIDTf;

@end

@implementation QYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *chatVC = segue.destinationViewController;
    [chatVC setValue:_selfIDTf.text forKey:@"selfID"];
    [chatVC setValue:_friendIDTf.text forKey:@"friendID"];
    
}


@end
