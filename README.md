# HSL OpenMaaS - Mobile Client Library

Library for displaying HSL tickets.

Usage requires registration in [HSL OpenMaas developer portal](https://sales-api.hsl.fi/portal).

## Example projects:

This repository includes examples for both React Native app and Native (Java / Objective-C) apps. Feel free to use either of the examples as a base for your own app.

You can find React Native example project [here](./example/react-native), and native examples [here](./example/native).

In order to purchase tickets, you will need your own backend server. You should not call the order ticket endpoint directly from the mobile app! You can find example Node.js server that can also be used to test the app [here](./example/server).

## Requirements:
  - react-native >= 0.52.
  - react
  - [react-native-code-push](https://docs.microsoft.com/en-us/appcenter/distribution/codepush/react-native#getting-started)*
  - [react-native-svg](https://github.com/react-native-community/react-native-svg)
  - [react-native-device-info](https://github.com/rebeccahughes/react-native-device-info)

*Note: You need HSL CodePush deployment keys in order to use Client Library. Without the keys you won't be able to fetch tickets. You can get the keys after registering to [HSL OpenMaas developer portal](https://sales-api.hsl.fi/portal).

  ##### Recommended
  - [Yarn](https://yarnpkg.com/lang/en/)
  - [react-native-cli](https://www.npmjs.com/package/react-native-cli) installed globally

## Getting stated:

Move your iOS related files to a `/ios` folder and Android related files to `/android` folder in your project root.

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

#### iOS:
  1. Add fonts from `src/fonts` folder to your iOS project. Remember to add them into `info.plist` also!

  2. Add `main.jsbundle` from `src/ios` to your project root.

  3. Add CodePush deployment key to your `info.plist`. You can get the deployment key from HSL OpenMaaS development portal.

  4. Override default CodePush app version to get the correct bundle, e.g.
  ```objectivec
  // Objective C
  NSString *appVersion = @"<HSL CLIENT LIBRARY SEMVERSION NUMBER HERE e.g. 1.0.0>";
  [CodePush overrideAppVersion:(NSString *)appVersion];
  ```

  5. Create array of initial properties:
  ```objectivec
  // Objective C
  NSDictionary *initialProps = @{
    @"organizationId" : @"<YOU WILL GET THIS FROM HSL OPEN MAAS DEVELOPER PORTAL AFTER REGISTERING>",
    @"clientId" : @"<THIS IS THE SAME CLIENT ID YOU USE TO ORDER TICKETS>",
    @"dev" : @"YES", // Remove this if you want to start using production api
  };
  ```

  6. Initialize the RCTRootView with:
  ```objectivec
  // Objective C
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
    moduleName:@"clientlib"
    initialProperties:initialProps
    launchOptions:launchOptions];
  ```

#### Android:
  1. Add fonts from `src/fonts` folder to your project.

  2. Add `index.android.bundle` from `src/android` to your project `app/assets` folder

  3. Add the following code to your `MainActivity.java` file:
  ```java
  package com.yourexampleapp;

  import android.os.Bundle;
  import com.facebook.react.ReactActivity;
  import com.facebook.react.ReactActivityDelegate;


  public class MainActivity extends ReactActivity {

    /**
    * Returns the name of the main component registered from JavaScript.
    * This is used to schedule rendering of the component.
    */
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
          initialProps.putString("organizationId", "<YOU WILL GET THIS FROM HSL OPEN MAAS DEVELOPER PORTAL AFTER REGISTERING>");
          initialProps.putString("clientId", "<THIS IS THE SAME CLIENT ID YOU USE TO ORDER TICKETS>");
          initialProps.putString("dev", "YES"); // Remove this if you want to start using production api
          return initialProps;
        }
      };
    }
  }
  ```

  4. On `MainApplication.java` you should still override `onCreate` method and add the following:
  ```java
  CodePush.overrideAppVersion("<HSL CLIENT LIBRARY SEMVERSION NUMBER HERE e.g. 1.0.0>");
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
