package com.example;

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
                initialProps.putString("dev", "yes");
                return initialProps;
            }
        };
    }
}
