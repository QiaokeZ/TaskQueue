//
//  Task.h
//  TaskQueue <https://github.com/QiaokeZ/iOS_TaskQueue>
//
//  Created by zhouqiao on 2022/8/4.
//  Copyright © 2022 zhouqiao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>
#import "TaskQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject
@property(nonatomic, readonly) TaskState state;
@property(nonatomic, readonly) NSString *identifier;
- (void)wait;
- (void)start;
- (void)pause;
- (void)dispose;
- (void)finish;
@end

NS_ASSUME_NONNULL_END
