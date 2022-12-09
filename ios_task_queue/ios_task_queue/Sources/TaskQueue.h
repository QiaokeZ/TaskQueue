//
//  TaskQueue.h
//  TaskQueue <https://github.com/QiaokeZ/iOS_TaskQueue>
//
//  Created by zhouqiao on 2022/8/4.
//  Copyright © 2022 zhouqiao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

@class Task;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaskState) {
    TaskStateWaiting,
    TaskStateRunning,
    TaskStatePaused,
    TaskStateFinished,
};

static NSInteger const TaskQueueDefaultMaxTaskCount = -1;

@interface TaskQueue<__covariant ObjectType:Task *> : NSObject

+ (instancetype)queue;

@property(nonatomic) NSInteger maxTaskCount;
@property(nonatomic, readonly, nullable) NSArray<ObjectType> *tasks;

- (BOOL)containsIdentifier:(NSString *)identifier;

- (BOOL)addTask:(ObjectType)task forIdentifier:(NSString *)identifier;

- (nullable ObjectType)taskForIdentifier:(NSString *)identifier;

- (void)performBatchHandler:(void(^)(void))handler;

- (void)startTask:(NSString *)identifier;

- (void)pauseTask:(NSString *)identifier;

- (void)removeTask:(NSString *)identifier;

- (void)startAllTasks;

- (void)pauseAllTasks;

- (void)removeAllTasks;

@end

NS_ASSUME_NONNULL_END
