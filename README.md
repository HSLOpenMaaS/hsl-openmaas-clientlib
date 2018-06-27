# HSL OpenMaaS - Mobile Client Library

Library for displaying HSL tickets bought through [HSL Sales Api](https://sales-api.hsl.fi/public-docs).

Usage requires registration in [HSL OpenMaas Developer Portal](https://sales-api.hsl.fi).

## Table of Contents

* [Requirements](#requirements)
* [Example projects](#example-projects)
* [Getting started](#getting-started)
    * [First steps](#first-steps)
    * [Integrating Client Library to your app](#integrating-client-library-to-your-app)
      * [iOS](#ios)
      * [Android](#android)
* [FAQ](#faq)
* [License](#license)

## Requirements
  - react-native >= 0.52.
  - react
  - [react-native-code-push](https://docs.microsoft.com/en-us/appcenter/distribution/codepush/react-native#getting-started)*
  - [react-native-svg](https://github.com/react-native-community/react-native-svg)
  - [react-native-device-info](https://github.com/rebeccahughes/react-native-device-info)

*Note: You need HSL CodePush deployment keys in order to use the Client Library. Without the keys you won't be able to fetch tickets. You can get the keys after registering to HSL OpenMaas developer portal.

  ##### Recommended
  - [Yarn](https://yarnpkg.com/lang/en/)
  - [react-native-cli](https://www.npmjs.com/package/react-native-cli) installed globally

## Example projects

This repository includes examples for both React Native app and Native (Java / Objective-C) apps. Feel free to use either of the examples as a base for your own app.

You can find React Native example project [here](./example/react-native), and native examples [here](./example/native).

To order tickets, you will need your own backend server. You should not call the order ticket endpoint directly from the mobile app! You can find example Node.js server that can also be used to test the app [here](./example/server).

## Getting started

### First steps

You will first need to build an application that handles ticket orders. You can use one of our [examples](./examples) for testing purposes.

HSL Sales Api ticket order endpoint requires you to send end-user device Id as a parameter. You can get the device ID with one of the following ways:

```javascript
// React Native (using react-native-device-info)
const deviceId = DeviceInfo.getUniqueID();
```

```objectivec
// iOS (Obj-C)
NSString *deviceId = [DeviceUID uid]; 
```

```java
// Android (Java)
String deviceId = Secure.getString(getActivity().getApplicationContext().getContentResolver(), Secure.ANDROID_ID);
```

### Integrating Client Library to your app

This example is written mainly for projects created with `react-native init` or `create-react-native-app` that have then been ejeced.

If you are integrating Client Library to an existing native app, move your iOS related files to a `/ios` folder and Android related files to `/android` folder in your project root first. You can also look how our [native examples](./example/native) are done.

Create `package.json` to your project root and add required node modules with `yarn add <module>`, e.g.:
```
yarn add react-native ...
``` 

Link libraries with:
```
react-native link react-native-code-push
react-native link react-native-svg
react-native link react-native-device-info
```
* NOTE: If you don't want to use `react-native-cli`, look up the instructions to manual linking from Appcenter CodePush documents or each packages own GitHub page. Links in the Requirements section of this readme.

You can ignore CodePush deployment keys at this point of installation and press enter with default values, but if you have already registered to HSL OpenMaas developer portal, you can type the keys when asked.

#### iOS
  1. Add `main.jsbundle` from `src/ios` to your project root.

  2. Add CodePush deployment key to your `info.plist`. You can get the deployment key from HSL OpenMaaS development portal.

  3. Override default CodePush app version to get the correct bundle, e.g.
  ```objectivec
  // Objective C
  // Version number of the Client Library you are using. See GitHub releases.
  NSString *appVersion = @"1.2.0";
  [CodePush overrideAppVersion:(NSString *)appVersion];
  ```

  4. Create array of initial properties:
  ```objectivec
  // Objective C
  NSDictionary *initialProps = @{
    // You will get this from HSL OpenMaaS Developer Portal after registering.
    @"organizationId" : @"Your organizationId here", 
    // This must be the same clientId you used for ordering ticket.
    @"clientId" : @"clientId here", 
    // "YES" if you want to use sandbox endpoints, "" if you want to use production endpoints.
    @"dev" : @"YES", 
  };
  ```

  5. Initialize the RCTRootView with:
  ```objectivec
  // Objective C
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
    moduleName:@"clientlib"
    initialProperties:initialProps
    launchOptions:launchOptions];
  ```

#### Android
  1. Add `index.android.bundle` from `src/android` to your project `app/assets` folder

  2. Add the following code to your Activity file:
  ```java
  // ...

  import android.os.Bundle;
  import com.facebook.react.ReactActivity;
  import com.facebook.react.ReactActivityDelegate;

  // ...

  public class MainActivity extends ReactActivity {

    @Override
    protected String getMainComponentName() {
      return "clientlib";
    }

    @Override
    protected ReactActivityDelegate createReactActivityDelegate() {
      return new ReactActivityDelegate(this, getMainComponentName()) {
        @Override
        protected Bundle getLaunchOptions() {
          Bundle initialProps = new Bundle();
          // You will get this from HSL OpenMaaS Developer Portal after registering.
          initialProps.putString("organizationId", "<YOUR ORGANIZATION ID HERE>");
          // This has to be the same clientId you used for ordering ticket.
          initialProps.putString("clientId", "<CLIENT ID HERE>");
          // "YES" if you want to use sandbox endpoints, "" if you want to use production endpoints.
          initialProps.putString("dev", "YES"); 
          return initialProps;
        }
      };
    }
  }
  ```

  3. On `MainApplication.java` you should override `onCreate` method and add the following:
  ```java
  // Version number of the Client Library you are using. See GitHub releases.
  CodePush.overrideAppVersion("1.2.0");
  ```

  Also be sure to change this:
  ```java
   @Override
    protected String getJSMainModuleName() {
      return "example";
    }
  ```
  to this:
  ```java
  @Override
    protected String getJSMainModuleName() {
      return "clientlib";
    }
  ```

## FAQ

See: [HSL OpenMaas Developer Portal (bottom of the page)](https://sales-api.hsl.fi/)

## License

[MIT](./LICENSE)
