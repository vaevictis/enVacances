//
//  EnVacances_AppDelegate.m
//  EnVacances
//
//  Created by vaevictis on 26/02/11.
//  Copyright sogilis 2011 . All rights reserved.
//

#import "EnVacances_AppDelegate.h"

@implementation EnVacances_AppDelegate

@synthesize window;

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "EnVacances" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"EnVacances"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
    [super dealloc];
}


// Non-generated code
@synthesize totalExpenses;
@synthesize totalStayDurations;
@synthesize dailyCost;

- (IBAction) makeAccounts:(id)sender{
	NSLog(@"gonna call 'computeBalance'");
	[self computeBalance];
}

- (void) computeBalance
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSError *error = nil;

	// Setting total expenses
	NSEntityDescription *expenseEntity = [NSEntityDescription entityForName:@"Expense"
													 inManagedObjectContext:managedObjectContext];

	[request setEntity:expenseEntity];	
	NSArray *expensesArray = [managedObjectContext executeFetchRequest:request error:&error];
	
	NSDecimalNumber *amountsSum = nil;
	for (NSDictionary *expensesDictionary in expensesArray) {
        NSDecimalNumber *amount = (NSDecimalNumber *) [expensesDictionary valueForKey:@"amount"];
        if (!amountsSum) {
			amountsSum = amount;
        } else {
			amountsSum = [amountsSum decimalNumberByAdding:amount];
        }
	}
	
	totalExpenses = amountsSum;
	
	// Setting total user days
	NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User"
												  inManagedObjectContext:managedObjectContext];
	[request setEntity:userEntity];	
	NSArray *usersArray = [managedObjectContext executeFetchRequest:request error:&error];
	
	int stayDurationsSum = 0;
	for (NSDictionary *userDictionary in usersArray) {
		int stayDuration = [[userDictionary valueForKey:@"stayDuration"] intValue];
		stayDurationsSum = stayDurationsSum + stayDuration;
	}

	totalStayDurations = [NSNumber numberWithInt:stayDurationsSum];

	// Setting interface elements
	[totalExpensesField setFloatValue: [totalExpenses floatValue]];
	[totalStayDurationsField setIntValue: [totalStayDurations intValue]];
	
	// Computing the daily cost
	dailyCost = [NSNumber numberWithFloat:[amountsSum floatValue] / stayDurationsSum];
	[dailyCostField setFloatValue:[dailyCost floatValue]];
	
	// Computing balance
	for (NSManagedObject *user in [usersArray objectEnumerator]) {
		NSString *name = [user valueForKey:@"name"];
		NSLog(@"user name: %@", name);
		
		NSArray *expensesArray = [user valueForKey:@"expenses"];
		float totalUserAmount = 0.0;
		for (NSManagedObject *expense in [expensesArray objectEnumerator]) {
			float expenseAmount = [[expense valueForKey:@"amount"] floatValue];
			NSLog(@"expense amount: %f", expenseAmount);
			
			totalUserAmount = totalUserAmount + expenseAmount;
			NSLog(@"intermediate total amount : %f", totalUserAmount);		
		}

		NSLog(@"total amount: %f", totalUserAmount);
		
		float balance = totalUserAmount - [dailyCost floatValue] * [[user valueForKey:@"stayDuration"] floatValue];
		NSLog(@"balance: %f", balance);
		NSNumber *userBalance = [NSNumber numberWithFloat:balance];
		[user setValue:userBalance 
				forKey:@"balance"];
		NSLog(@"balance fetchée: %@", [user valueForKey:@"balance"]);
	}
}

@end
