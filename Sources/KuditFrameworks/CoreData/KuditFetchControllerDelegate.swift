//
//  KuditFetchControllerDelegate.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 9/18/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
    
/*
 extension Set where Element: IndexPath {
 mutating func removeItemsIn(sections: NSIndexSet) {
 for indexPath in self {
 if sections.contains(indexPath.section) {
 self.remove(indexPath)
 }
 }
 }
 }
 
 public class KuditFetchControllerDelegate: NSObject {
 var _view: UIView // UITableView or UICollectionView
 
 var _indexPathsToDelete: NSMutableSet
 var _indexPathsToInsert: NSMutableSet
 var _indexPathsToUpdate: NSMutableSet
 var _sectionsToDelete: NSMutableIndexSet
 var _sectionsToInsert: NSMutableIndexSet
 var _sectionsToUpdate: NSMutableIndexSet
 var _movePairs: NSMutableSet
 
 override init() {
 super.init()
 }
 }
 + (void) load {
 // make sure required dependancies are present
 assert([NSFetchedResultsController instancesRespondToSelector:@selector(performFetch)]); // Make sure NSFetchedResultsController+kudit is included
 }
 
 - (id) initWithView: (id) view {
 if ((self = [super init])) {
 _view = view;
 }
 return self;
 }
 
 - (void) dealloc {
 [[NSNotificationCenter defaultCenter] removeObserver:self];
 }
 
 + (KuditFetchControllerDelegate*) fetchControllerDelegateWithView: (id) view {
 return [[KuditFetchControllerDelegate alloc] initWithView:view];
 }
 
 #pragma mark - fetch controller delegate methods
 
 - (BOOL) _isTableView {
 return [_view isKindOfClass:[UITableView class]];
 }
 
 - (void) controllerWillReplaceContent: (NSFetchedResultsController*) controller {
 //    NSLog(@"KFCD: Replaced all content");
 [_view reloadData];
 }
 
 - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
 //    NSLog(@"KFCD: controller will change content");
 // queue up changes to batch update on completion
 _indexPathsToDelete = [NSMutableSet set];
 _indexPathsToInsert = [NSMutableSet set];
 _indexPathsToUpdate = [NSMutableSet set];
 _sectionsToDelete = [NSMutableIndexSet indexSet];
 _sectionsToInsert = [NSMutableIndexSet indexSet];
 _sectionsToUpdate = [NSMutableIndexSet indexSet];
 _movePairs = [NSMutableSet set];
 }
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
 atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
 switch(type) {
 case NSFetchedResultsChangeInsert:
 [_sectionsToInsert addIndex:sectionIndex];
 break;
 case NSFetchedResultsChangeDelete:
 [_sectionsToDelete addIndex:sectionIndex];
 break;
 case NSFetchedResultsChangeUpdate:
 [_sectionsToUpdate addIndex:sectionIndex];
 break;
 default:
 NSLog(@"KFCD: Unknown change type %d for section index %lu", (int)type, (unsigned long)sectionIndex);
 break;
 }
 }
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
 atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
 newIndexPath:(NSIndexPath *)newIndexPath {
 
 switch(type) {
 case NSFetchedResultsChangeInsert:
 [_indexPathsToInsert addObject:newIndexPath];
 break;
 case NSFetchedResultsChangeDelete:
 [_indexPathsToDelete addObject:indexPath];
 break;
 case NSFetchedResultsChangeUpdate:
 [_indexPathsToUpdate addObject:indexPath];
 break;
 case NSFetchedResultsChangeMove:
 [_movePairs addObject:@[indexPath,newIndexPath]];
 break;
 default:
 NSLog(@"KFCD: Unknown change type %d for indexPath %@", (int)type, indexPath);
 break;
 }
 }
 
 // called after fetched results controller received a content change notification
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 //    NSLog(@"KFCD: controller did change content");
 if ([self _isTableView]) {
 UITableView *tableView = _view;
 [tableView beginUpdates];
 if ([_sectionsToInsert count] > 0) {
 [tableView insertSections:_sectionsToInsert
 withRowAnimation:UITableViewRowAnimationFade];
 }
 if ([_sectionsToDelete count] > 0) {
 [tableView deleteSections:_sectionsToDelete
 withRowAnimation:UITableViewRowAnimationFade];
 }
 if ([_sectionsToUpdate count] > 0) {
 [tableView reloadSections:_sectionsToUpdate withRowAnimation:UITableViewRowAnimationFade];
 }
 if ([_indexPathsToInsert count] > 0) {
 [tableView insertRowsAtIndexPaths:[_indexPathsToInsert allObjects]
 withRowAnimation:UITableViewRowAnimationFade];
 }
 if ([_indexPathsToDelete count] > 0) {
 [tableView deleteRowsAtIndexPaths:[_indexPathsToDelete allObjects]
 withRowAnimation:UITableViewRowAnimationFade];
 }
 if ([_indexPathsToUpdate count] > 0) {
 [tableView reloadRowsAtIndexPaths:[_indexPathsToUpdate allObjects]
 withRowAnimation:UITableViewRowAnimationNone];
 }
 [tableView endUpdates];
 } else {
 UICollectionView *collectionView = _view;
 if ([self _shouldReloadCollectionViewFromChangedContent]) { // hack to fix bugs and unusual section changes
 [collectionView reloadData];
 } else {
 // extra validation for special cases
 __block NSMutableSet *blockIndexPathsToInsert;
 [collectionView performBatchUpdates:^() {
 if ([_sectionsToDelete count] > 0) {
 [collectionView deleteSections:_sectionsToDelete];
 }
 if ([_sectionsToInsert count] > 0) {
 [collectionView insertSections:_sectionsToInsert];
 }
 if ([_sectionsToUpdate count] > 0) {
 [collectionView reloadSections:_sectionsToUpdate];
 }
 if ([_movePairs count] > 0) {
 for (NSArray *pair in _movePairs) {
 NSIndexPath *fromIndexPath = pair[0];
 NSIndexPath *toIndexPath = pair[1];
 // make sure not included in updates
 [_indexPathsToUpdate removeObject:fromIndexPath];
 [_indexPathsToUpdate removeObject:toIndexPath];
 // make sure not moving from a deleted section
 if ([_sectionsToDelete containsIndex:fromIndexPath.section]) {
 // just do the other half
 [_indexPathsToInsert addObject:toIndexPath];
 break; // don't do move
 }
 // or to an inserted section
 if ([_sectionsToInsert containsIndex:toIndexPath.section]) {
 // just delete original
 [_indexPathsToDelete addObject:fromIndexPath];
 break; // don't do move
 }
 [collectionView moveItemAtIndexPath:pair[0] toIndexPath:pair[1]];
 }
 }
 [_indexPathsToDelete removeItemsInSections:_sectionsToDelete]; // already deleting via section, so no need to include here
 [_indexPathsToInsert removeItemsInSections:_sectionsToInsert]; // already being inserted by the section insert
 if ([_indexPathsToDelete count] > 0) {
 [collectionView deleteItemsAtIndexPaths:[_indexPathsToDelete allObjects]];
 }
 if ([_indexPathsToInsert count] > 0) {
 // make sure we're not double-dipping with the updates
 [_indexPathsToUpdate removeItemsInSet:_indexPathsToInsert];
 [collectionView insertItemsAtIndexPaths:[_indexPathsToInsert allObjects]];
 }
 if ([_indexPathsToUpdate count] > 0) {
 // just update cell data because reloading the cell will ruin the selection state
 for (NSIndexPath *indexPath in _indexPathsToUpdate) {
 [[collectionView cellForItemAtIndexPath:indexPath] setNeedsLayout];
 }
 }
 blockIndexPathsToInsert = _indexPathsToInsert; // save in case something else gets triggered during this to reset the local indexPathsToInsert variable
 // after inserting cells (animated), cells may need to trigger their own animations
 NSInteger numberOfSections = [collectionView numberOfSections];
 [_sectionsToInsert enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
 // same goes for inserted section cells
 if (section < numberOfSections) { // make sure we don't try to do this on a section that no longer exists (say it was inserted but more sections were deleted!
 NSInteger count = [collectionView numberOfItemsInSection:section];
 for (int item = 0; item < count; item++) {
 NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
 [blockIndexPathsToInsert addObject:indexPath];
 }
 }
 }];
 } completion:^(BOOL finished) {
 // do the updates
 for (NSIndexPath *indexPath in blockIndexPathsToInsert) {
 [[collectionView cellForItemAtIndexPath:indexPath] setNeedsLayout];
 }
 }];
 }
 }
 }
 
 // This is to prevent a bug in UICollectionView from occurring.
 // The bug presents itself when inserting the first object or deleting the last object in a collection view.
 // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
 // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
 // http://openradar.appspot.com/12954582
 - (BOOL) _shouldReloadCollectionViewFromChangedContent {
 UICollectionView *collectionView = _view;
 NSInteger totalNumberOfIndexPaths = 0;
 for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
 totalNumberOfIndexPaths += [collectionView numberOfItemsInSection:section];
 }
 
 NSInteger numberOfItemsAfterUpdates = totalNumberOfIndexPaths;
 numberOfItemsAfterUpdates += _indexPathsToInsert.count;
 numberOfItemsAfterUpdates -= _indexPathsToDelete.count;
 
 if (numberOfItemsAfterUpdates == 0 && totalNumberOfIndexPaths == 1) {
 return YES;
 }
 
 if (numberOfItemsAfterUpdates == 1 && totalNumberOfIndexPaths == 0) {
 return YES;
 }
 
 // see if sections are off
 NSInteger originalNumberOfSections = [collectionView numberOfSections];
 NSInteger proposedNumberOfSections = originalNumberOfSections + [_sectionsToInsert count] - [_sectionsToDelete count];
 NSInteger targetNumberOfSections = [collectionView.dataSource numberOfSectionsInCollectionView:collectionView];
 if (proposedNumberOfSections != targetNumberOfSections) {
 // something special is going on here.  let's just give up and reload all data
 return YES;
 //                if (proposedNumberOfSections < targetNumberOfSections) {
 //                    // there will be a new section created.  probably better to just reload the data instead of figuring out what went wrong
 //                    [collectionView reloadData];
 //                    return;
 //                } else {
 //                    // there was a section deleted.  Perhaps we can determine which sections deleted based on items deleted
 //                    NSMutableIndexSet *possibleSectionsToDelete = [NSMutableIndexSet indexSet];
 //                    for (NSIndexPath *indexPath in _indexPathsToDelete) {
 //                        [possibleSectionsToDelete addIndex:indexPath.section];
 //                    }
 //                    // if the deleted sections makes things hunky dory then let's do that!
 //                    if (proposedNumberOfSections - [possibleSectionsToDelete count] == targetNumberOfSections) {
 //                        // yippee!  Delete those sections and remove the index paths to delete
 //                        [_indexPathsToDelete removeAllObjects];
 //                        [_sectionsToDelete addIndexes:possibleSectionsToDelete];
 //                        // continue on our merry way
 //                    } else {
 //                        // oh fuck, what happened?  Let's just reload
 //                        [collectionView reloadData];
 //                        return;
 //                    }
 //                }
 }
 
 // see if total items are off
 NSInteger totalExpectedNumberOfIndexPaths = 0;
 for (NSInteger section = 0; section < [collectionView.dataSource numberOfSectionsInCollectionView:collectionView]; section++) {
 totalExpectedNumberOfIndexPaths += [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
 }
 if (totalExpectedNumberOfIndexPaths != numberOfItemsAfterUpdates) {
 return YES;
 }
 return NO;
 }
 */
#endif

