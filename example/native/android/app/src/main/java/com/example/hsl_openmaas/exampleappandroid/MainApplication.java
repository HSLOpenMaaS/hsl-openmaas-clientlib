package com.example.hsl_openmaas.exampleappandroid;

import android.app.Application;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.horcrux.svg.SvgPackage;
import com.learnium.RNDeviceInfo.RNDeviceInfo;
import com.microsoft.codepush.react.CodePush;

import java.util.Arrays;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {

    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        protected String getJSBundleFile() { return CodePush.getJSBundleFile(); }

        @Override
        public List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                new MainReactPackage(),
                new CodePush(BuildConfig.CODEPUSH_DEPLOYMENT_KEY, MainApplication.this, false),
                new RNDeviceInfo(),
                new SvgPackage()
            );
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() { return mReactNativeHost; }

    @Override
    public void onCreate() {
        super.onCreate();
        CodePush.overrideAppVersion(BuildConfig.HSL_CLIENT_LIBRARY_VERSION);
    }
}