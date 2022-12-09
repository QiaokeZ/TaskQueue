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

#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface Task (Private)
@property(nonatomic) TaskState state;
@property(nonatomic) NSString *identifier;
@property(nonatomic, getter=isEnabled) BOOL _enabled;
- (void)_setIdentifier:(NSString *)identifier finishHandler:(void(^)(void))handler;
- (void)_start;
- (void)_pause;
- (void)_dispose;
@end

NS_ASSUME_NONNULL_END
