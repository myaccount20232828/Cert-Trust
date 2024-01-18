#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Utilities.h"

PSGCertTrustSettings* getCertTrustSettings(void) {
    PSGCertTrustSettings* certTrustSettings = [objc_getClass("PSGCertTrustSettings") alloc];
    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	myView.backgroundColor = [UIColor redColor];
	certTrustSettings.view = myView;
    return certTrustSettings;
}

SecCertificateRef getCertificateAtPath(NSString* certificatePath) {
    NSData* certificateData = [NSData dataWithContentsOfFile: certificatePath];
    if (certificateData == NULL) {
        return NULL;
    }
    SecCertificateRef certificateRef = SecCertificateCreateWithData(kCFAllocatorMalloc, (__bridge CFDataRef)certificateData);
    return certificateRef;
}

void trustCertificate(NSString* certificatePath, PSGCertTrustSettings* certTrustSettings) {
    SecCertificateRef certificateRef = getCertificateAtPath(certificatePath);
    if (certificateRef == NULL) {
        return;
    }
    [certTrustSettings setFullTrustEnabled: @YES forSpecifier: [certTrustSettings specifierForTrustSettings: certificateRef isRestricted: false]];
}
