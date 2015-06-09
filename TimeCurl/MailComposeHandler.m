/*
 
 Copyright (C) 2013-2015, Patrick Jayet
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
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
