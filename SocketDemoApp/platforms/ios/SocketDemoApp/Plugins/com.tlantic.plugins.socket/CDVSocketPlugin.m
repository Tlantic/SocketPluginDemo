#import "CDVSocketPlugin.h"
#import "Connection.h"
#import <cordova/CDV.h>

@implementation CDVSocketPlugin


- (NSString*)buildKey :(NSString*)host :(int)port {
    NSString* tempHost = [host lowercaseString];
    NSString* tempPort = [NSString stringWithFormat:@"%d", port];
    
    return  [[tempHost stringByAppendingString:@":"] stringByAppendingString:tempPort];
}



- (void)connect:(CDVInvokedUrlCommand*)command
{
    // validating parameters
    if ([command.arguments count] < 2) {
        
        // triggering parameter error
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments when calling 'connect' action."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    } else {
        
        // checking connection pool
        if (!pool) {
            self->pool = [[NSMutableDictionary alloc] init];
        }
        
        
        // running in background to avoid thread locks
        [self.commandDelegate runInBackground:^{
            
            CDVPluginResult* result= nil;
            Connection* socket = nil;
            NSString* key = nil;
            NSString* host = nil;
            int port = 0;
            
            // opening connection and adding into pool
            @try {
                
                // preparing parameters
                host = [command.arguments objectAtIndex:0];
                port = [[command.arguments objectAtIndex:1] integerValue];
                key = [self buildKey:host :port];
                
                // checking existing connections
                if ([pool objectForKey:key]) {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:key];
                    NSLog(@"Recovered connection with %@", key);
                } else {
                    
                    // creating connection
                    socket = [[Connection alloc] initWithNetworkAddress:host :port];
                    [socket setDelegate:self];
                    [socket open];
                    
                    // adding to pool
                    [self->pool setObject:socket forKey:key];
                    
                    //formatting success response
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:key];
                    NSLog(@"Established connection with %@", key);
                }
            }
            @catch (NSException *exception) {
                NSLog(@"Exception: %@", exception);
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unexpected exception when executing 'connect' action."];
            }
            
            //returning callback resolution
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            
        }];
        
    }
    
}



-(Boolean) disposeConnection :(NSString *)host :(int)port {
    
    NSString *key = nil;
    Connection* socket = nil;
    Boolean result = false;
    
    
    @try {
        // preparing parameters
        key = [self buildKey:host :port];
        
        
        // getting connection from pool
        socket = [pool objectForKey:key];
        
        // closing connection
        if (socket) {
            [pool removeObjectForKey:key];
            [socket close];
            socket = nil;
            
            NSLog(@"Closed connection with %@", key);
        } else {
            NSLog(@"Connection %@ already closed!", key);
        }
        
        // setting success
        result = true;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception when closing connection: %@", exception);
        result = false;
    }
    @finally {
        return result;
    }
}



- (void)disconnect:(CDVInvokedUrlCommand*)command
{
    // validating parameters
    if ([command.arguments count] < 2) {
        // triggering parameter error
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments when calling 'disconnect' action."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    } else {
        
        // running in background to avoid thread locks
        [self.commandDelegate runInBackground:^{
            
            CDVPluginResult* result= nil;
            NSString* host = nil;
            int port = 0;
            
            @try {
                // preparing parameters
                host = [command.arguments objectAtIndex:0];
                port = [[command.arguments objectAtIndex:1] integerValue];


                // closing socket
                if ([self disposeConnection:host :port]) {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                } else {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unable to close connection!"];
                }
                
            }
            @catch (NSException *exception) {
                NSLog(@"Exception: %@", exception);
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unexpected exception when executing 'disconnect' action."];
            }
            
            //returning callback resolution
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
        
    }
    
}

-(void) disconnectAll: (CDVInvokedUrlCommand *) command {

    // running in background to avoid thread locks
    [self.commandDelegate runInBackground:^{
       
        CDVPluginResult* result = nil;
        Connection * socket = nil;
        Boolean *partial = false;
        
        @try {
            
            // iterating connection pool
            for (id key in pool) {
                socket = [pool objectForKey:key];
                
                // try close it
                if (![self disposeConnection:socket.host :socket.port]) {
                    partial = FALSE;
                }
            }
            
            //formatting result
            if (partial) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Some connections could not be closed."];
                
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@", exception);
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unexpected exception when executing 'disconnectAll' action."];
        }
        @finally {
            //returning callback resolution
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
        
    }];
    
}


-(void)send: (CDVInvokedUrlCommand *) command {
    
    // validating parameters
    if ([command.arguments count] < 3) {
        // triggering parameter error
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing arguments when calling 'send' action."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    } else {
        
        // running in background to avoid thread locks
        [self.commandDelegate runInBackground:^{
            
            CDVPluginResult* result= nil;
            Connection* socket = nil;
            NSString* data = nil;
            NSString* key = nil;
            NSString* host = nil;
            int port = 0;
            
            @try {
                // preparing parameters
                host = [command.arguments objectAtIndex:0];
                port = [[command.arguments objectAtIndex:1] integerValue];
                key = [self buildKey:host :port];
                
                // getting connection from pool
                socket = [pool objectForKey:key];
                
                // writting on output stream
                data = [command.arguments objectAtIndex:2];
                [socket write:data];
                
                //formatting success response
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:key];
                NSLog(@"Sending data to %@ - %@", key, data);
            }
            @catch (NSException *exception) {
                NSLog(@"Exception: %@", exception);
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unexpected exception when executon 'send' action."];
            }
            
            //returning callback resolution
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
        
        
    }
}




-(void) sendMessage :(NSString *)host :(int)port :(NSString *)chunk {
    
    // handling escape chars
    NSMutableString *data = [NSMutableString stringWithString:chunk];
    [data replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [data length])];
    
    // relay to webview
    NSString *receiveHook= [NSString stringWithFormat:@"window.tlantic.plugins.socket.receive('%@', %d, '%@' );", host, port, [NSString stringWithString:data]];
    [self writeJavascript:receiveHook];
    
}
@end