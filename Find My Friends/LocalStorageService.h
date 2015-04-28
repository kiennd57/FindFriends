//
//  LocalStorageService.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>


#define kCurrentUser @"kCurrentUser"

@interface LocalStorageService : NSObject

@property (nonatomic, strong) QBUUser *currentUser;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, readonly) NSDictionary *usersAsDictionary;
@property (nonatomic, readonly) NSArray *checkins;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) QBCOCustomObject *currentEvent;
@property (nonatomic, strong) NSArray *userList;

+ (instancetype)sharedInstance;
- (void)setUsers:(NSArray *)users;
- (void)saveCheckins:(NSArray *)checkins;
- (void)saveCurrentUser:(QBUUser *)user;
- (void)setEvents:(NSArray *)events;
- (void)saveEvents:(NSArray *)events;
- (void)saveCurrentEvent:(QBCOCustomObject *)currentEvent;
- (void)saveUserList: (NSArray *)userList;
- (void)uploadFile:(NSData *)data withObjectID:(NSString *)objID;

@end
