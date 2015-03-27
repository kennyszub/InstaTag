//
//  BOXPaginatedItemArrayRequest.h
//  BoxContentSDK
//

#import "BOXItemArrayRequest.h"

@interface BOXPaginatedItemArrayRequest : BOXItemArrayRequest

- (instancetype)initWithFolderID:(NSString *)folderID inRange:(NSRange)range;

@end
