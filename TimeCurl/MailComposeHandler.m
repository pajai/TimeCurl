/*
 
 Copyright 2013-2015 Patrick Jayet
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
*/

#import "MailComposeHandler.h"

@implementation MailComposeHandler

- (id)init {
    self = [super init];
    if (self) {
		
		// default: no HTML
		self.isHtml = NO;
		
	}
    return self;
}

- (void) prepareMailComposeViewController;
{
	if (![MFMailComposeViewController canSendMail]) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-mail not configured"
														message:@"Please configure first the e-mail service on your device."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		
	}
	else {
		
		MFMailComposeViewController* composeSheet = [[MFMailComposeViewController alloc] init];
		
		if (self.subject != nil) {
			[composeSheet setSubject:self.subject];
		}
		
		if (self.body != nil) {
			[composeSheet setMessageBody:self.body isHTML:self.isHtml];
		}
		
		if (self.to != nil) {
			[composeSheet setToRecipients:[NSArray arrayWithObject:self.to]];
		}
        
        if (self.attachmentName != nil && self.attachmentMime != nil && self.attachmentData != nil) {
            [composeSheet addAttachmentData:self.attachmentData mimeType:self.attachmentMime fileName:self.attachmentName];
        }
		
		composeSheet.mailComposeDelegate = self;

        self.mailComposeController = composeSheet;
	}
}

#pragma mark - Dismiss Mail/SMS view controller

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	
	NSString* errMsg = nil;
	switch (result)
	{
		case MFMailComposeResultCancelled:
			// no error
			break;
		case MFMailComposeResultSaved:
			// no error
			break;
		case MFMailComposeResultSent:
			// no error
			break;
		case MFMailComposeResultFailed:
			errMsg = @"An error occured while sending the e-mail";
			NSLog(@"Error occured while sending mail: MFMailComposeResultFailed");
			break;
	}
	
    [self.mailComposeController dismissViewControllerAnimated:YES completion:nil];
	if (self.delegate != nil) {
        [self.delegate mailComposeCallback];
    }
    
	if (errMsg != nil) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-mail"
														message:errMsg
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
	}
	
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
				 didFinishWithResult:(MessageComposeResult)result {
	
    [self.mailComposeController dismissViewControllerAnimated:YES completion:nil];
	if (self.delegate != nil) {
        [self.delegate mailComposeCallback];
    }
	
}

@end
