//
//  SSHKitConnector.m
//  SSHKitCore
//
//  Created by Yang Yubo on 12/23/14.
//
//

#import "SSHKitConnector.h"
#import "SSHKitConnectorProxy.h"
#import "CoSocket.h"
#import "CoSOCKSMessage.h"
#import "SSHKitConnector+Protected.h"

NSData * CSConnectLocalResolveHost(NSString *host, uint16_t port, NSError **errPtr)
{
    NSMutableArray *addresses = [CoSocket lookupHost:host port:port error:errPtr];
    
    if (errPtr&&*errPtr) {
        return nil;
    }
    
    NSData *address4 = nil;
    
    // TODO: IPv6
    NSData *address6 = nil;
    
    for (NSData *address in addresses)
    {
        if (!address4 && [CoSocket isIPv4Address:address])
        {
            address4 = address;
        }
        else if (!address6 && [CoSocket isIPv6Address:address])
        {
            address6 = address;
        }
    }
    
    if (!address4) {
        NSString *desc = [NSString stringWithFormat:@"can't resolve hostname: %@", host];
        *errPtr = [NSError errorWithDomain:@"com.codinn.proxycommand"
                                      code:-1
                                  userInfo:@{ NSLocalizedDescriptionKey : desc }];
    }
    
    return address4;
}

@implementation SSHKitConnector

- (instancetype)initWithTimeout:(NSTimeInterval)timeout
{
    if((self = [super init])) {
        self.timeout = timeout;
    }
    
    return self;
}

- (void)dealloc
{
    [self disconnect];
}

- (BOOL)connectToTarget:(NSString *)host onPort:(uint16_t)port error:(NSError **)errPtr
{
    self.targetHost = host;
    self.targetPort = port;
    
    _coSocket = [[CoSocket alloc] initWithHost:self.targetHost onPort:self.targetPort];
    
    if (![_coSocket connect]) {
        if (errPtr) *errPtr = _coSocket.lastError;
        return NO;
    }
    
    return YES;
}


- (void)disconnect
{
    if (_coSocket) {
        [_coSocket shutdown];
        [_coSocket close];
    }
    
    _coSocket = nil;
}

- (int)dupSocketFD
{
    if (_coSocket.sockfd > 0) {
        return dup(_coSocket.sockfd);
    }
    
    return 0;
}

@end