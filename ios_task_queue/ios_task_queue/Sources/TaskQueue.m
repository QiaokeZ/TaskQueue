//
//  TaskQueue.m
//  TaskQueue <https://github.com/QiaokeZ/TaskQueue>
//
//  Created by zhouqiao on 2022/8/4.
//  Copyright © 2022 zhouqiao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "Task.h"
#import "TaskQueue.h"
#import "Task+Private.h"

@interface TaskQueue()
@property(nonatomic) NSMutableArray<Task *> *elements;
@property(nonatomic, getter=isEnabled) BOOL enabled;
@property(nonatomic) NSMutableDictionary<NSString *, Task *> *taskKeyedByIdentifier;
@end

@implementation TaskQueue

+ (instancetype)queue {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
        self.elements = [NSMutableArray array];
        self.taskKeyedByIdentifier = [NSMutableDictionary dictionary];
        self.maxTaskCount = TaskQueueDefaultMaxTaskCount;
    }
    return self;
}

- (void)setMaxTaskCount:(NSInteger)maxTaskCount {
    if (_maxTaskCount != maxTaskCount) {
        _maxTaskCount = MAX(TaskQueueDefaultMaxTaskCount, maxTaskCount);
        [self execute];
    }
}

- (NSArray *)tasks {
    return self.elements.copy;
}

- (BOOL)containsIdentifier:(NSString *)identifier {
    return [self taskForIdentifier:identifier] != nil;
}

- (BOOL)addTask:(Task *)task forIdentifier:(NSString *)identifier {
    @synchronized (self) {
        if([self containsIdentifier:identifier]) return NO;
        [task _setIdentifier:identifier finishHandler:^{
            [self removeTask:identifier];
        }];
        self.taskKeyedByIdentifier[identifier] = task;
        [self.elements addObject:task];
        return YES;
    }
}

- (void)performBatchHandler:(void(^)(void))handler {
    if (handler) {
        self.enabled = NO;
        handler();
        self.enabled = YES;
        [self execute];
    }
}

- (void)startTask:(NSString *)identifier {
    @synchronized (self) {
        Task *task = [self taskForIdentifier:identifier];
        if (task) {
            task._enabled = YES;
            [self execute];
        }
    }
}

- (void)pauseTask:(NSString *)identifier {
    @synchronized (self) {
        Task *task = [self taskForIdentifier:identifier];
        if (task) {
            task._enabled = NO;
            [self execute];
        }
    }
}

- (void)removeTask:(NSString *)identifier {
    @synchronized (self) {
        Task *task = [self taskForIdentifier:identifier];
        if (task) {
            [task _dispose];
            [self.taskKeyedByIdentifier removeObjectForKey:task.identifier];
            [self.elements removeObject:task];
            [self execute];
        }
    }
}

- (void)startAllTasks {
    [self performBatchHandler:^{
        for (Task *task in self.tasks) {
            task._enabled = YES;
        }
    }];
}

- (void)pauseAllTasks {
    [self performBatchHandler:^{
        for (Task *task in self.tasks) {
            task._enabled = NO;
        }
    }];
}

- (void)removeAllTasks {
    [self performBatchHandler:^{
        [self.taskKeyedByIdentifier removeAllObjects];
        NSEnumerator *enumerator = [self.elements objectEnumerator];
        Task *obj = nil;
        while (obj = [enumerator nextObject]) {
            [obj dispose];
            [self.elements removeObject:obj];
        }
    }];
}

- (Task *)taskForIdentifier:(NSString *)identifier {
    return self.taskKeyedByIdentifier[identifier];
}

- (void)execute {
    if (!self.isEnabled) return;
    NSInteger activeCount = [self activeCount];
    for (Task *task in self.tasks) {
        if (!task.isEnabled && task.state == TaskStateRunning) {
            [task _pause];
        }
        if (self.maxTaskCount != TaskQueueDefaultMaxTaskCount) {
            if (self.maxTaskCount < activeCount && task.state == TaskStateRunning) {
                [task _pause];
            }
        }
    }
    BOOL belowMaxTask = [self belowMaxTask];
    for (Task *task in self.tasks) {
        if (belowMaxTask && task.isEnabled && task.state != TaskStateRunning) {
            [task _start];
            belowMaxTask = [self belowMaxTask];
        }
    }
}

- (BOOL)belowMaxTask {
    if (self.maxTaskCount == TaskQueueDefaultMaxTaskCount) {
        return YES;
    }
    return self.activeCount < self.maxTaskCount;
}

- (NSInteger)activeCount {
    NSInteger count = 0;
    for (NSString *key in self.taskKeyedByIdentifier) {
        Task *task = self.taskKeyedByIdentifier[key];
        if (task.state == TaskStateRunning) {
            count++;
        }
    }
    return count;
}

@end
