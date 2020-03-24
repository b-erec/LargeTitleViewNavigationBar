//
//  NSObject+KVO.m
//  LargeTitleView
//
//  Created by berec on 24/03/2020.
//  Copyright © 2020 Noname. All rights reserved.
//

#import "NSObject+KVO.h"

#import <objc/runtime.h>

@implementation NSObject (KVO)

#pragma mark - Accessors

- (NSMutableDictionary<NSString *, KVObserver> *)blockObservers {
    const void *key = @selector(blockObservers);
    NSMutableDictionary *observers = objc_getAssociatedObject(self, key);
    if (!observers) {
        observers = [NSMutableDictionary new];
        objc_setAssociatedObject(self, key, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return observers;
}

#pragma mark - Public

- (void)addBlockObserverForKeyPath:(NSString *)keyPath observer:(KVObserver)observer {
    __auto_type observers = [self blockObservers];
    
    if (observers[keyPath]) {
        [observers setObject:observer forKey:keyPath];
        return;
    }

    [observers setObject:observer forKey:keyPath];
    [self addObserver:self
           forKeyPath:keyPath
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:nil];
}

- (void)removeBlockObserverForKeyPath:(NSString *)keyPath {
    __auto_type observers = [self blockObservers];
    if (observers[keyPath]) {
        [observers removeObjectForKey:keyPath];
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (void)removeAllBlockObservers {
    [[self blockObservers] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, KVObserver  _Nonnull obj, BOOL * _Nonnull stop) {
        [self removeObserver:self forKeyPath:key];
    }];
    [[self blockObservers] removeAllObjects];
}

#pragma mark - Private

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    KVObserver observer = [self blockObservers][keyPath];
    if (observer) {
        observer(change);
    }
}

@end
