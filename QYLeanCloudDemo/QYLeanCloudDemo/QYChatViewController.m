//
//  QYChatViewController.m
//  QYLeanCloudDemo
//
//  Created by 云菲 on 3/31/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYChatViewController.h"
#import "QYMessageCell.h"

#import "UIView+Extension.h"

#import <AVOSCloudIM.h>

@interface QYChatViewController () <UITableViewDelegate, UITableViewDataSource, AVIMClientDelegate>
@property (weak, nonatomic) IBOutlet UITextView *messageTv;//文本输入框
@property (weak, nonatomic) IBOutlet UITableView *tableView;//消息列表
@property (weak, nonatomic) IBOutlet UIView *bottomView;//底部视图
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) AVIMClient *client;
@property (strong, nonatomic) AVIMConversation *conversation;

@property (strong, nonatomic) NSMutableArray *messages;


@end

@implementation QYChatViewController

#pragma mark - Life Cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //创建会话
    [self createConversation];
    
    //初始化数据源
    _messages = [NSMutableArray array];
    
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    //配置tableView
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTableView:)];
    [self.tableView addGestureRecognizer:tap];
    self.tableView.estimatedRowHeight = 60;
    
}

#pragma mark - Custom Methods
-(void)createConversation{
    [self.client openWithCallback:^(BOOL succeeded, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        //创建会话查询对象
        AVIMConversationQuery *query = [self.client conversationQuery];
        //创建查询条件，该会话中包括的所有成员列表
        [query whereKey:@"m" containsAllObjectsInArray:@[_selfID, _friendID]];
        //创建查询条件，该会话中包括2名成员
        [query whereKey:@"m" sizeEqualTo:2];
        //查询符合条件的会话
        [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
                return;
            }
            
            if (objects.count == 0) {//如果没有符合条件的会话，就创建一个新会话
                // _selfID 建立了与 _friendID 的会话
                [self.client createConversationWithName:[NSString stringWithFormat:@"%@和%@", _selfID, _friendID] clientIds:@[_friendID] callback:^(AVIMConversation *conversation, NSError *error) {
                    if (error) {
                        NSLog(@"%@", error);
                        _messageTv.userInteractionEnabled = NO;//如果会话创建失败，则禁止用户输入文本
                        return;
                    }
                    _conversation = conversation;
                }];
            }else{//如果有符合条件的会话，则可以直接使用
                _conversation = objects.firstObject;
            }
        }];
        
    }];
}

#pragma mark - Events
-(void)keyboardWillShown:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];//键盘大小
    NSInteger duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] integerValue];//键盘出现的动画时长
    //为了使键盘不遮挡住视图，_bottomView和_tableView统一上移
    _bottomConstraint.constant = keyboardRect.size.height;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)keyboardWillHidden:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSInteger duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] integerValue];//键盘消失的动画时长
    //恢复视图原始位置
    _bottomConstraint.constant = 0;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

//发送消息
- (IBAction)sendMessage:(UIButton *)sender {
    AVIMMessage *message = [AVIMMessage messageWithContent:_messageTv.text];
    [_conversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"发送失败");
        }
         _messageTv.text = @"";
    }];
    
    [_messages addObject:message];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)tapOnTableView:(UITapGestureRecognizer *)tap{
    [_messageTv resignFirstResponder];
}

#pragma mark - AVIMClient Delegate
-(void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message{
    [_messages addObject:message];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QYMessageCell *cell;
    AVIMMessage *message = _messages[indexPath.row];
    if ([message.clientId isEqualToString:_selfID]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"rightCell"];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"QYRightMessageCell" owner:nil options:nil][0];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"leftCell"];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"QYLeftMessageCell" owner:nil options:nil][0];
        }
    }
    
        
    cell.message = message;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_messageTv resignFirstResponder];
}



#pragma mark - Getters
-(AVIMClient *)client{
    if (_client == nil) {
        _client = [[AVIMClient alloc] initWithClientId:_selfID];
        _client.messageQueryCacheEnabled = NO;//是否打开本地缓存功能
        _client.delegate = self;
    }
    return _client;
}

@end
