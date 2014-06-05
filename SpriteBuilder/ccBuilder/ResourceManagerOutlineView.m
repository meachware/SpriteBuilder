/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ResourceManagerOutlineView.h"
#import "AppDelegate.h"
#import "ResourceContextMenu.h"
#import "ResourceActionController.h"
#import "NotificationNames.h"

@implementation ResourceManagerOutlineView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deselectAll:)
                                                     name:RESOURCES_CHANGED
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMenu *)menuForEvent:(NSEvent *)evt
{
	// NW: It's called to draw a highlight on the right clicked item,
	// the menu outlet of the outline view has to be just set as well
	[super menuForEvent:evt];

	NSPoint clickedPoint = [self convertPoint:[evt locationInWindow] fromView:nil];
	int row = [self rowAtPoint:clickedPoint];

	id clickedItem = [self itemAtRow:row];

    ResourceContextMenu *resourceContextMenu = [[ResourceContextMenu alloc] initWithResource:clickedItem
                                                                                actionTarget:_actionTarget
                                                                                   resources:[self selectedResources]];

    return resourceContextMenu;
}

- (NSArray *)selectedResources
{
    NSMutableArray *result = [NSMutableArray array];
    NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];

    [selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        id object = [self itemAtRow:idx];
        if (object)
        {
            [result addObject:object];
        }
    }];

    // If right click is not within selection just return the right clicked resource
    // Otherwise move it to the beginng of returned objects
    NSInteger index = [self clickedRow];
    id clickedObject = [self itemAtRow:index];
    if (clickedObject)
    {
        if ([result containsObject:clickedObject])
        {
            NSUInteger clickedObjectIndexInResult = [result indexOfObject:clickedObject];
            [result removeObjectAtIndex:clickedObjectIndexInResult];
        }
        else
        {
            [result removeAllObjects];
        }
        [result insertObject:clickedObject atIndex:0];
    }

    return result;
}

- (void) keyDown:(NSEvent *)theEvent
{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter)
    {
        [[ResourceActionController sharedController] deleteResources:[self selectedResources]];
        return;
    }
    
    [super keyDown:theEvent];
}

@end
