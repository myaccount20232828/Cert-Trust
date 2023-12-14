#import "TSUtil.h"
#import <Foundation/Foundation.h>
#import <spawn.h>
#import <sys/sysctl.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1
extern int posix_spawnattr_set_persona_np(const posix_spawnattr_t* __restrict, uid_t, uint32_t);
extern int posix_spawnattr_set_persona_uid_np(const posix_spawnattr_t* __restrict, uid_t);
extern int posix_spawnattr_set_persona_gid_np(const posix_spawnattr_t* __restrict, uid_t);

NSString* getNSStringFromFile(int fd)
{
    NSMutableString* ms = [NSMutableString new];
    ssize_t num_read;
    char c;
    while((num_read = read(fd, &c, sizeof(c))))
    {
        [ms appendString:[NSString stringWithFormat:@"%c", c]];
    }
    return ms.copy;
}

NSString* spawnRoot(NSString* path, NSArray* args)
{
    NSMutableArray* argsM = args.mutableCopy ?: [NSMutableArray new];
    [argsM insertObject:path.lastPathComponent atIndex:0];
    
    NSUInteger argCount = [argsM count];
    char **argsC = (char **)malloc((argCount + 1) * sizeof(char*));

    for (NSUInteger i = 0; i < argCount; i++)
    {
        argsC[i] = strdup([[argsM objectAtIndex:i] UTF8String]);
    }
    argsC[argCount] = NULL;

    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);

    posix_spawnattr_set_persona_np(&attr, 99, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
    posix_spawnattr_set_persona_uid_np(&attr, 0);
    posix_spawnattr_set_persona_gid_np(&attr, 0);

    posix_spawn_file_actions_t action;
    posix_spawn_file_actions_init(&action);

    //int outErr[2];

    int out[2];
    pipe(out);
    posix_spawn_file_actions_adddup2(&action, out[1], STDOUT_FILENO);
    posix_spawn_file_actions_addclose(&action, out[0]);
    
    pid_t task_pid;
    int status = -200;
    int spawnError = posix_spawn(&task_pid, [path UTF8String], &action, &attr, (char* const*)argsC, NULL);
    posix_spawnattr_destroy(&attr);
    for (NSUInteger i = 0; i < argCount; i++)
    {
        free(argsC[i]);
    }
    free(argsC);
    
    if(spawnError != 0)
    {
        return @"0";
    }

    do
    {
        if (waitpid(task_pid, &status, 0) != -1) {
        } else
        {
            return @"-222";
        }
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
    close(out[1]);
    NSString* output = getNSStringFromFile(out[0]);
    //printf("%s\n", output.UTF8String);
    return output;
}

void enumerateProcessesUsingBlock(void (^enumerator)(pid_t pid, NSString* executablePath, BOOL* stop))
{
	static int maxArgumentSize = 0;
	if (maxArgumentSize == 0) {
		size_t size = sizeof(maxArgumentSize);
		if (sysctl((int[]){ CTL_KERN, KERN_ARGMAX }, 2, &maxArgumentSize, &size, NULL, 0) == -1) {
			perror("sysctl argument size");
			maxArgumentSize = 4096; // Default
		}
	}
	int mib[3] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL};
	struct kinfo_proc *info;
	size_t length;
	int count;
	
	if (sysctl(mib, 3, NULL, &length, NULL, 0) < 0)
		return;
	if (!(info = malloc(length)))
		return;
	if (sysctl(mib, 3, info, &length, NULL, 0) < 0) {
		free(info);
		return;
	}
	count = length / sizeof(struct kinfo_proc);
	for (int i = 0; i < count; i++) {
		@autoreleasepool {
		pid_t pid = info[i].kp_proc.p_pid;
		if (pid == 0) {
			continue;
		}
		size_t size = maxArgumentSize;
		char* buffer = (char *)malloc(length);
		if (sysctl((int[]){ CTL_KERN, KERN_PROCARGS2, pid }, 3, buffer, &size, NULL, 0) == 0) {
			NSString* executablePath = [NSString stringWithCString:(buffer+sizeof(int)) encoding:NSUTF8StringEncoding];
			
			BOOL stop = NO;
			enumerator(pid, executablePath, &stop);
			if(stop)
			{
				free(buffer);
				break;
			}
		}
		free(buffer);
		}
	}
	free(info);
}

void InjectTweak(NSString* BundleID, NSString* TweakPath) {
	[[LSApplicationWorkspace defaultWorkspace] openApplicationWithBundleID: BundleID];
	enumerateProcessesUsingBlock(^(pid_t pid, NSString* executablePath, BOOL* stop) {
		NSString* InfoPlistPath = [NSString stringWithFormat:@"%@/Info.plist", [executablePath stringByDeletingLastPathComponent]];
		NSDictionary* InfoPlist = [[NSDictionary alloc] initWithContentsOfFile: InfoPlistPath];
		if (InfoPlist) {
			if ([[InfoPlist objectForKey: @"CFBundleIdentifier"] isEqualToString: BundleID]) {
				NSString* OpaInjectPath = @"/var/jb/usr/bin/opainject";
				NSString* fastPathSignPath = @"/var/jb/usr/bin/fastPathSign";
				printf("PID: %d\nTweak Path: %s\n", (int)pid, TweakPath.UTF8String);
				printf("Signing %s\n", TweakPath.UTF8String);
				spawnRoot(fastPathSignPath, @[TweakPath]);
				printf("Injecting tweak into %s\n", BundleID.UTF8String);
				[[LSApplicationWorkspace defaultWorkspace] openApplicationWithBundleID: BundleID];
   	 			spawnRoot(OpaInjectPath, @[@(pid).stringValue, TweakPath]);
				printf("Done!\n");
			}
		}
	});
}
