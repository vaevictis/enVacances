//
//  EnVacances_AppDelegate.h
//  EnVacances
//
//  Created by vaevictis on 26/02/11.
//  Copyright sogilis 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EnVacances_AppDelegate : NSObject 
{
    NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	// Non-generated code
	IBOutlet NSButton *openAccountsWindow;
	IBOutlet NSButton *closeAccountsWindow;

	IBOutlet NSWindow *accountsWindow;
	IBOutlet NSTextField *accountsField;
	NSNumber *accounts;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;

// Non-generated code
- (IBAction) openAccountsWindow:(id)sender;
- (IBAction) closeAccountsWindow:(id)sender;
- (void) makeAccounts;

@property(assign) NSNumber *accounts;

@end
