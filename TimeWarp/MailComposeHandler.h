//
//  MailComposeHandler.h
//  GlobalRadio
//
//  Created by pat on 27.03.2013.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "MailComposeCallbackDelegate.h"


@interface MailComposeHandler : NSObject <MFMailComposeViewControllerDelegate>

- (void) prepareMailComposeViewController;

@property (nonatomic, strong) MFMailComposeViewController* mailComposeController;

@property (nonatomic, strong) NSString* to;
@property (nonatomic, strong) NSString* subject;
@property (nonatomic, strong) NSString* body;
@property (nonatomic, strong) NSString* attachmentName;
@property (nonatomic, strong) NSString* attachmentMime;
@property (nonatomic, strong) NSData* attachmentData;
@property (readwrite) BOOL isHtml;

@property (nonatomic, retain) id<MailComposeCallbackDelegate> delegate;

@end
