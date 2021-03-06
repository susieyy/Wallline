/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

// up-front decl's
@class FBSession;
@class FBSessionTokenCachingStrategy;

#define FB_SESSIONSTATETERMINALBIT (1 << 8)

#define FB_SESSIONSTATEOPENBIT (1 << 9)

/*
 * Constants used by NSNotificationCenter for active session notification
 */

/*! NSNotificationCenter name indicating that a new active session was set */
extern NSString *const FBSessionDidSetActiveSessionNotification;

/*! NSNotificationCenter name indicating that an active session was unset */
extern NSString *const FBSessionDidUnsetActiveSessionNotification;

/*! NSNotificationCenter name indicating that the active session is open */
extern NSString *const FBSessionDidBecomeOpenActiveSessionNotification;

/*! NSNotificationCenter name indicating that there is no longer an open active session */
extern NSString *const FBSessionDidBecomeClosedActiveSessionNotification;

/*! 
 @typedef FBSessionState enum
 
 @abstract Passed to handler block each time a session state changes
 
 @discussion
 */
typedef enum {
    /*! One of two initial states indicating that no valid cached token was found */
    FBSessionStateCreated                   = 0,
    /*! One of two initial session states indicating that a cached token was loaded;
     when a session is in this state, a call to open* will result in an open session,
     without UX or app-switching*/
    FBSessionStateCreatedTokenLoaded        = 1,
    /*! One of three pre-open session states indicating that an attempt to open the session
     is underway*/
    FBSessionStateCreatedOpening            = 2,
    
    /*! Open session state indicating user has logged in or a cached token is available */
    FBSessionStateOpen                      = 1 | FB_SESSIONSTATEOPENBIT,
    /*! Open session state indicating token has been extended */
    FBSessionStateOpenTokenExtended         = 2 | FB_SESSIONSTATEOPENBIT,
    
    /*! Closed session state indicating that a login attempt failed */
    FBSessionStateClosedLoginFailed         = 1 | FB_SESSIONSTATETERMINALBIT, // NSError obj w/more info
    /*! Closed session state indicating that the session was closed, but the users token 
        remains cached on the device for later use */
    FBSessionStateClosed                    = 2 | FB_SESSIONSTATETERMINALBIT, // "
} FBSessionState;

/*! helper macro to test for states that imply an open session */
#define FB_ISSESSIONOPENWITHSTATE(state) (0 != (state & FB_SESSIONSTATEOPENBIT))

/*! helper macro to test for states that are terminal */
#define FB_ISSESSIONSTATETERMINAL(state) (0 != (state & FB_SESSIONSTATETERMINALBIT))

/*! 
 @typedef FBSessionLoginBehavior enum
 
 @abstract 
 Passed to login to indicate whether Facebook Login should allow for fallback to be attempted.
 
 @discussion
 Facebook Login authorizes the application to act on behalf of the user, using the user's 
 Facebook account. Usually a Facebook Login will rely on an account maintained outside of 
 the application, by the native Facebook application, the browser, or perhaps the device
 itself. This avoids the need for a user to enter their username and password directly, and
 provides the most secure and lowest friction way for a user to authorize the application to
 interact with Facebook. If a Facebook Login is not possible, a fallback Facebook Login may be 
 attempted, where the user is prompted to enter their credentials in a web-view hosted directly
 by the application. 
 
 The `FBSessionLoginBehavior` enum specifies whether to allow fallback, disallow fallback, or
 force fallback login behavior. Most applications will use the default, which attempts a normal
 Facebook Login, and only falls back if needed. In rare cases, it may be preferable to disalow
 fallback Facebook Login completely, or to force a fallback login.
 */
typedef enum {
    /*! Attempt Facebook Login, ask user for credentials if necessary */
    FBSessionLoginBehaviorWithFallbackToWebView      = 0,
    /*! Attempt Facebook Login, no direct request for credentials will be made */
    FBSessionLoginBehaviorWithNoFallbackToWebView    = 1,
    /*! Only attempt WebView Login; ask user for credentials */
    FBSessionLoginBehaviorForcingWebView             = 2,
} FBSessionLoginBehavior;

/*! 
 @typedef
 
 @abstract Block type used to define blocks called by <FBSession> for state updates
 @discussion
 */
typedef void (^FBSessionStateHandler)(FBSession *session, 
                                       FBSessionState status, 
                                       NSError *error);

/*! 
 @typedef
 
 @abstract Block type used to define blocks called by <[FBSession reauthorizeWithPermissions]>/.
 
 @discussion
 */
typedef void (^FBSessionReauthorizeResultHandler)(FBSession *session, 
                                                  NSError *error);

/*! 
 @class FBSession

 @abstract
 The `FBSession` object is used to authenticate a user and manage the user's session. After
 initializing a `FBSession` object the Facebook App ID and desired permissions are stored. 
 Opening the session will initiate the authentication flow after which a valid user session
 should be available and subsequently cached. Closing the session can optionally clear the
 cache.
 
 If an  <FBRequest> request requires user authorization then an `FBSession` object should be used.

 
 @discussion
 Instances of the `FBSession` class provide notification of state changes in the following ways:
 
 1. Callers of certain `FBSession` methods may provide a block that will be called
 back in the course of state transitions for the session (e.g. login or session closed).
 
 2. The object supports Key-Value Observing (KVO) for property changes.
 */
@interface FBSession : NSObject

/*!
 @methodgroup Creating a session
 */

/*!
 @method

 @abstract 
 Returns a newly initialized Facebook session with default values for the parameters
 to <initWithAppID:permissions:urlSchemeSuffix:tokenCacheStrategy:>.
 */
- (id)init;

/*!
 @method
 
 @abstract
 Returns a newly initialized Facebook session with the specified permissions and other
 default values for parameters to <initWithAppID:permissions:urlSchemeSuffix:tokenCacheStrategy:>.
 
 @param permissions  An array of strings representing the permissions to request during the
 authentication flow. A value of nil will indicates basic permissions. The default is nil.

 */
- (id)initWithPermissions:(NSArray*)permissions;

/*!
 @method
 
 @abstract
 Following are the descriptions of the arguments along with their 
 defaults when ommitted.
 
 @param permissions  An array of strings representing the permissions to request during the
 authentication flow. A value of nil will indicates basic permissions. The default is nil.
 @param appID  The Facebook App ID for the session. If nil is passed in the default App ID will be obtained from a call to <[FBSession defaultAppID]>. The default is nil.
 @param urlSchemeSuffix  The URL Scheme Suffix to be used in scenarious where multiple iOS apps use one Facebook App ID. A value of nil indicates that this information should be pulled from the plist. The default is nil.
 @param tokenCachingStrategy Specifies a key name to use for cached token information in NSUserDefaults, nil
 indicates a default value of @"FBAccessTokenInformationKey".
 */
- (id)initWithAppID:(NSString*)appID
           permissions:(NSArray*)permissions
       urlSchemeSuffix:(NSString*)urlSchemeSuffix
    tokenCacheStrategy:(FBSessionTokenCachingStrategy*)tokenCachingStrategy;

// instance readonly properties         

/*! @abstract Indicates whether the session is open and ready for use. */
@property(readonly) BOOL isOpen;                      

/*! @abstract Detailed session state */
@property(readonly) FBSessionState state;              

/*! @abstract Identifies the Facebook app which the session object represents. */
@property(readonly, copy) NSString *appID;              

/*! @abstract Identifies the URL Scheme Suffix used by the session. This is used when multiple iOS apps share a single Facebook app ID. */
@property(readonly, copy) NSString *urlSchemeSuffix;    

/*! @abstract The access token for the session object. */
@property(readonly, copy) NSString *accessToken;

/*! @abstract The expiration date of the access token for the session object. */
@property(readonly, copy) NSDate *expirationDate;    

/*! @abstract The permissions granted to the access token during the authentication flow. */
@property(readonly, copy) NSArray *permissions;

/*!
 @methodgroup Instance methods
 */

/*! 
 @method

 @abstract Opens a session for the Facebook.

 @discussion
 A session may not be used with <FBRequest> and other classes in the SDK until it is open. If, prior 
 to calling open, the session is in the <FBSessionStateCreatedTokenLoaded> state, then no UX occurs, and 
 the session becomes available for use. If the session is in the <FBSessionStateCreated> state, prior
 to calling open, then a call to open causes login UX to occur, either via the Facebook application
 or via mobile Safari.
 
 Open may be called at most once and must be called after the `FBSession` is initialized. Open must
 be called before the session is closed. Calling an open method at an invalid time will result in
 an exception. The open session methods may be passed a block that will be called back when the session
 state changes. The block will be released when the session is closed.

 @param handler A block to call with the state changes. The default is nil.
*/
- (void)openWithCompletionHandler:(FBSessionStateHandler)handler;

/*! 
 @method
 
 @abstract Logs a user on to Facebook.
 
 @discussion
 A session may not be used with <FBRequest> and other classes in the SDK until it is open. If, prior 
 to calling open, the session is in the <FBSessionStateCreatedTokenLoaded> state, then no UX occurs, and 
 the session becomes available for use. If the session is in the <FBSessionStateCreated> state, prior
 to calling open, then a call to open causes login UX to occur, either via the Facebook application
 or via mobile Safari.
 
 The method may be called at most once and must be called after the `FBSession` is initialized. It must
 be called before the session is closed. Calling the method at an invalid time will result in
 an exception. The open session methods may be passed a block that will be called back when the session
 state changes. The block will be released when the session is closed.
 
 @param behavior Controls whether to allow, force, or prohibit Facebook Login or Inline Facebook Login. The default
 is to allow Facebook Login, with fallback to Inline Facebook Login.
 @param handler A block to call with session state changes. The default is nil.
 */
- (void)openWithBehavior:(FBSessionLoginBehavior)behavior
       completionHandler:(FBSessionStateHandler)handler;

/*!
 @abstract
 Closes the local in-memory session object, but does not clear the persisted token cache.
 */
- (void)close;

/*!
 @abstract
 Closes the in-memory session, and clears any persisted cache related to the session.
*/
- (void)closeAndClearTokenInformation;

/*!
 @abstract
 Reauthorizes the session, with additional permissions.
  
 @param permissions An array of strings representing the permissions to request during the
 authentication flow. A value of nil will indicates basic permissions. The default is nil.
 @param behavior Controls whether to allow, force, or prohibit Facebook Login. The default
 is to allow Facebook Login and fall back to Inline Facebook Login if needed.
 @param handler A block to call with session state changes. The default is nil.
 */
- (void)reauthorizeWithPermissions:(NSArray*)permissions
                          behavior:(FBSessionLoginBehavior)behavior
                 completionHandler:(FBSessionReauthorizeResultHandler)handler;

/*!
 @abstract
 A helper method that is used to provide an implementation for 
 [UIApplicationDelegate application:openURL:sourceApplication:annotation:]. It should be invoked during
 the Facebook Login flow and will update the session information based on the incoming URL.
 
 @param url The URL as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
*/
- (BOOL)handleOpenURL:(NSURL*)url;

/*!
 @methodgroup Class methods
 */

/*!
 @abstract
 This is the simplest method for opening a session with Facebook. Using sessionOpen logs on a user,
 and sets the static activeSession which becomes the default session object for any Facebook UI widgets
 used by the application. This session becomes the active session, whether open succeeds or fails.
 */
+ (FBSession*)sessionOpen;

/*!
 @abstract
 This is a simple method for opening a session with Facebook. Using sessionOpen logs on a user,
 and sets the static activeSession which becomes the default session object for any Facebook UI widgets
 used by the application. This session becomes the active session, whether open succeeds or fails.
 
 @param permissions     An array of strings representing the permissions to request during the
                        authentication flow. A value of nil will indicates basic permissions. 
                        A nil value specifies default permissions.
 
 @param handler         Many applications will benefit from notification when a session becomes invalid
                        or undergoes other state transitions. If a block is provided, the FBSession
                        object will call the block each time the session changes state.
 */
+ (FBSession*)sessionOpenWithPermissions:(NSArray*)permissions
                      completionHandler:(FBSessionStateHandler)handler;

/*!
 @abstract
 An appication may get or set the current active session. Certain high-level components in the SDK
 will use the activeSession to set default session (e.g. `FBLoginView`, `FBFriendPickerViewController`)
 
 @discussion
 If sessionOpen* is called, the resulting `FBSession` object also becomes the activeSession. If another
 session was active at the time, it is closed automatically. If activeSession is called when no session
 is active, a session object is instatiated and returned; in this case open must be called on the session
 in order for it to be useable for communication with Facebook.
 */
+ (FBSession*)activeSession;

/*!
 @abstract
 An appication may get or set the current active session. Certain high-level components in the SDK
 will use the activeSession to set default session (e.g. `FBLoginView`, `FBFriendPickerViewController`)
 
 @param session         The FBSession object to become the active session
 
 @discussion
 If an application prefers the flexibilility of directly instantiating a session object, an active
 session can be set directly.
 */
+ (FBSession*)setActiveSession:(FBSession*)session;

/*!
 @method
 
 @abstract Set the default Facebook App ID to use for sessions. The app ID may be
 overridden on a per session basis.
 
 @param appID The default Facebook App ID to use for <FBSession> methods.
 */
+ (void)setDefaultAppID:(NSString*)appID;

/*!
 @method
 
 @abstract Get the default Facebook App ID to use for sessions. If not explicitly
 set, the default will be read from the application's plist. The app ID may be
 overridden on a per session basis.
 */
+ (NSString*)defaultAppID;
    
@end
