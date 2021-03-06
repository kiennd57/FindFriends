//
//  LocalStorageService.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "LocalStorageService.h"

@implementation LocalStorageService

+ (instancetype)sharedInstance
{
	static id instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}

- (void)setEvents:(NSArray *)events
{
    _events = events;
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    
    NSMutableDictionary *__usersAsDictionary = [NSMutableDictionary dictionary];
    for(QBUUser *user in users){
        [__usersAsDictionary setObject:user forKey:@(user.ID)];
    }
    
    _usersAsDictionary = [__usersAsDictionary copy];
}

- (void)saveCheckins:(NSArray *)checkins
{
    _checkins = checkins;
}

- (void)saveCurrentUser:(QBUUser *)user
{
    _currentUser = user;
}

- (void)saveEvents:(NSArray *)events
{
    _events = events;
}

- (void)saveCurrentEvent:(QBCOCustomObject *)currentEvent {
    _currentEvent = currentEvent;
}

- (void)saveUserList:(NSArray *)userList {
    _userList = userList;
}

- (void)uploadFile:(NSData *)data withObjectID:(NSString *)objID {
    
    
    QBCOFile *file = [QBCOFile file];
    file.name = @"avatar";
    file.contentType = @"image/png";
    file.data = data;

    [QBRequest uploadFile:file className:@"UserProfile" objectID:objID fileFieldName:@"avatar" successBlock:^(QBResponse *response, QBCOFileUploadInfo *info) {
        
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        
    } errorBlock:^(QBResponse *response) {
        
    }];
}

- (void) saveUserProfiles:(NSArray *)userProfiles {
    _userProfiles = userProfiles;
}

@end
