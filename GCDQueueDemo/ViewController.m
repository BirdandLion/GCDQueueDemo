//
//  ViewController.m
//  GCDQueueDemo
//
//  Created by Kelvin on 17/2/14.
//  Copyright © 2017年 Kelvin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // GCD: grand central dispatch
    
    //    [self testAsyncOnCurrentQueue];
    
    // 1. 一段时间之后执行代码
    //    [self testAfter];
    
    // 2. 只执行一次,通常用来实现单例
    [self testOnce];
    [self testOnce];
    [self testOnce];
    [self testOnce];
    
    // 3. 同样代码执行多次
    //    [self testApply];
    
    // 4. 线程组的概念
    //    [self testGroup];
    
    // 5. barrier
    //实现的功能是: 在某几个线程执行完成之后,在另外的几个线程执行开始之前做一些操作
    //    [self testBarrier];
}

-(void)testBarrier
{
    //    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    // 注意: 这里不能使用系统的全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 执行线程一
    dispatch_async(queue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程一: %d", i);
        }
    });
    
    dispatch_async(queue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程二: %d", i);
        }
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"barrier");
    });
    
    // 执行线程三
    dispatch_async(queue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程三: %d", i);
        }
    });
    // 执行线程四
    dispatch_async(queue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程四: %d", i);
        }
    });
}

-(void)testGroup
{
    // 创建线程组
    dispatch_group_t group = dispatch_group_create();
    // 创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    /*
     para1: 线程组
     para2: 线程所在的队列
     para3: 线程执行体
     */
    dispatch_group_async(group, queue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程一: %d", i);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程二: %d", i);
        }
    });
    
    // 在线程组里面的所有线程执行完成之后,可以进行的一些操作
    // 在实际项目中:
    // 一个界面上面显示的数据需要放两个网络请求,并且要这两个请求的数据返回时不相互阻塞
    dispatch_group_notify(group, queue, ^{
        NSLog(@"线程组执行完成");
    });
}

-(void)testApply
{
    /*
     para1: 代码执行多少次
     para2: 线程所在的队列
     para3: 线程执行体
     */
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, globalConcurrentQueue, ^(size_t index) {
        // index 表示第几次执行
        NSLog(@"执行第%zu次", index); // size_t
    });
}

-(void)testOnce
{
    static dispatch_once_t onceToken;
    
    //    dispatch_once(&onceToken, ^{
    //        // 这里的代码只会执行一次
    //        NSLog(@"once");
    //    });
    
    dispatch_once(&onceToken, ^{
        NSLog(@"once");
    });
}

-(void)testAfter
{
    
    
    // 10秒之后执行
    /*
     para1: 参考的时间
     para2: 距离参考时间的间隔
     */
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 10);
    
    // 队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"Now");
    /*
     para1: 线程执行的时刻
     para2: 线程所在的队列
     para3: 线程的执行体
     */
    dispatch_after(when, globalQueue, ^{
        NSLog(@"十秒之后执行");
    });
}

// 异步方式向串行队列提交代码
// 前面的线程执行完成才开始执行后面的线程
-(void)testAsyncOnSerialQueue
{
    //    创建一个串行线程
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    // 异步提交代码
    dispatch_async(serialQueue, ^{
        // 这里是线程的执行体
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程一: %d", i);
        }
    });
    
    dispatch_async(serialQueue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程二: %d", i);
        }
    });
}

// 同步方式向串行队列提交代码
// 前面的线程执行完成才开始执行后面的线程
-(void)testSyncOnSerialQueue
{
    // 创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    // 同步提交代码
    void (^block)(void) = ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程一: %d", i);
        }
    };
    
    dispatch_sync(serialQueue, block);
    dispatch_sync(serialQueue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程二: %d", i);
        }
    });
}

// 同步的方式向并行队列提交代码
// 前面的线程执行完成才开始执行后面的线程
-(void)testSyncOnConCurrentQueue
{
    // 并行队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 同步提交代码
    void (^block1)(void) = ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程一: %d", i);
        }
    };
    void (^block2)(void) = ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程二: %d", i);
        }
    };
    
    dispatch_sync(globalQueue, block1);
    dispatch_sync(globalQueue, block2);
}

// 异步方式向并行队列提交代码
// 并行执行
-(void)testAsyncOnCurrentQueue
{
    // 并行队列
    dispatch_queue_t conCurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    // 异步提交代码
    void (^block1)(void) = ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程一: %d", i);
        }
    };
    void (^block2)(void) = ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程二: %d", i);
        }
    };
    
    dispatch_async(conCurrentQueue, block1);
    dispatch_async(conCurrentQueue, block2);
}

-(void)test
{
    // GCD thread list
    // 1. 主线程所在的串行队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // 2. 全局的并行队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 3. 自己创建队列
    // 并行队列
    dispatch_queue_t conQueue =  dispatch_queue_create("concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    // 串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    // 线程都是在队列里面执行
    //1. 将线程执行体异步放到队列里面
    dispatch_async(globalQueue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程一: %d", i);
        }
    }) ;
    
    //2.将线程执行体同步放到队列里面
    // 这种方式会阻塞线程
    //所以没有必要同步将线程放到主线程里面
    dispatch_sync(conQueue, ^{
        for(int i=0; i<100; i++)
        {
            NSLog(@"执行线程二: %d", i);
        }
    });
    
    // 总结
    /*
     只有将线程异步放到并列队列里面,才会同时执行多个线程
     
     其它方式都是前面的线程执行完成,才会执行后面的线程
     */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
