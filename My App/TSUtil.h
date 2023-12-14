#import <Foundation/Foundation.h>

NSString* getNSStringFromFile(int fd);
NSString* spawnRoot(NSString* path, NSArray* args);
void enumerateProcessesUsingBlock(void (^enumerator)(pid_t pid, NSString* executablePath, BOOL* stop));
void InjectTweak(NSString* BundleID, NSString* TweakPath);
