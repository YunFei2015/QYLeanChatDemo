//
//  QYMessageCell.m
//  QYLeanCloudDemo
//
//  Created by 云菲 on 3/31/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYMessageCell.h"
#import "UIView+Extension.h"

#import <AVIMMessage.h>

#define kMessageMaxWidth kMainScreenW / 2
#define kSelfHeight self.contentView.bounds.size.height

@interface QYMessageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *messageLab;
@end

@implementation QYMessageCell
-(void)awakeFromNib{
    _messageLab.preferredMaxLayoutWidth = kMessageMaxWidth;
}

-(void)setMessage:(AVIMMessage *)message{
    _message = message;
    _messageLab.text = message.content;
}
@end

@implementation QYLeftMessageCell
@end


@implementation QYRightMessageCell
@end
