//
//  SSHKitSFTP.m
//  SSHKitCore
//
//  Created by vicalloy on 8/26/15.
//
//

#import "SSHKitSFTPChannel.h"
#import "SSHKitCore+Protected.h"

@implementation SSHKitSFTPChannel

+ (void)freeSFTPAttributes:(sshkit_sftp_attributes)attributes {
    sftp_attributes_free(attributes);
}

- (instancetype)initWithDelegate:(id<SSHKitSFTPDelegate>)delegate {
    if (self = [super init]) {
        self->_delegate = delegate;
    }
    return self;
}

- (BOOL)initChannel:(SSHKitSession *)session {
    _sshSession = session;
    ssh_set_blocking(session.rawSession, 1);
    // if no blocking sftp_new will fail
    self->_rawSFTPSession = sftp_new(session.rawSession);
    ssh_set_blocking(session.rawSession, 0);
    if (self.rawSFTPSession == NULL) {
        // NSLog(@(ssh_get_error(session.rawSession)));
        return NO;
    }
    int rc = sftp_init(self.rawSFTPSession);
    if (rc != SSH_OK) {
        // fprintf(stderr, "Error initializing SFTP session: %s.\n", sftp_get_error(sftp));
        sftp_free(self.rawSFTPSession);
        self->_rawSFTPSession = NULL;
        // return rc;
        return NO;
    }
    return YES;
}

- (void)close {
    sftp_free(self.rawSFTPSession);
    self->_rawSFTPSession = NULL;
}

- (SSHKitSFTPFile *)openDirectory:(NSString *)path {
    SSHKitSFTPFile* directory = [[SSHKitSFTPFile alloc]init:self path:path isDirectory:YES];
    // TODO handle error
    [directory open];
    return directory;
}

- (SSHKitSFTPFile *)openFile:(NSString *)path {
    SSHKitSFTPFile* file = [[SSHKitSFTPFile alloc]init:self path:path isDirectory:NO];
    // TODO handle error
    [file open];
    return file;
}

@end
