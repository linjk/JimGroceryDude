//
//  CoreDataHelper.h
//  JimGroceryDude
//
//  Created by hodi on 10/19/15.
//  Copyright © 2015 LinJK. All rights reserved.
//
//  该类实例完成的任务：
//  1. 初始化托管对象模型
//  2. 根据托管对象模型来创建持久化存储区，并据此初始化持久化存储协调器
//  3. 根据持久化存储协调器来初始化托管对象上下文

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "MigrationVC.h"     //报告迁移进度

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext       *context;
@property (nonatomic, readonly) NSManagedObjectModel         *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSPersistentStore            *store;

@property (nonatomic, retain)   MigrationVC *migrationVC;

-(void)setupCoreData;
-(void)saveContext;

@end
