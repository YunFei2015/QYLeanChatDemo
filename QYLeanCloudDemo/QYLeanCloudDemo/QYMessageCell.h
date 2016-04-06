//
//  QYMessageCell.h
//  QYLeanCloudDemo
//
//  Created by 云菲 on 3/31/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVIMMessage;

@interface QYMessageCell : UITableViewCell
@property (strong, nonatomic) AVIMMessage *message;
@end


@interface QYLeftMessageCell : QYMessageCell

@end


@interface QYRightMessageCell : QYMessageCell

@end