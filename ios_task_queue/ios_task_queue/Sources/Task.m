//
//  Task.m
//  TaskQueue <https://github.com/QiaokeZ/iOS_TaskQueue>
//
//  Created by zhouqiao on 2022/8/4.
//  Copyright © 2022 zhouqiao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "Task+Private.h"

@interface Task()
@property(nonatomic) TaskState state;
@property(nonatomic) NSString *identifier;
@property(nonatomic, getter=isEnabled) BOOL _enabled;
@property(nonatomic, copy) void (^finishHandler)(void);
@end

@implementation Task

- (void)_setIdentifier:(NSString *)identifier finishHandler:(void(^)(void))handler {
    _finishHandler = handler;
    _identifier = identifier;
    [self _wait];
}

- (void)_wait {
    _state = TaskStateWaiting;
    [self wait];
}

- (void)_start {
    _state = TaskStateRunning;
    [self start];
}

- (void)_pause {
    _state = TaskStatePaused;
    [self pause];
}

- (void)_dispose {
    [self dispose];
}

- (void)finish {
    _state = TaskStateFinished;
    _finishHandler();
}

- (void)wait {}

- (void)start {}

- (void)pause {}

- (void)dispose {}

@end
