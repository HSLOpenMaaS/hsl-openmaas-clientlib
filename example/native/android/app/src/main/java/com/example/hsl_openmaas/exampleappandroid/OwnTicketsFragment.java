package com.example.hsl_openmaas.exampleappandroid;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;

public class OwnTicketsFragment extends Fragment {
    private ReactRootView mReactRootView;
    private ReactInstanceManager mReactInstanceManager;

    public OwnTicketsFragment () {
        // Required empty constructor
    }

    public static OwnTicketsFragment newInstance(String organizationId, String clientId, String dev) {
        OwnTicketsFragment fragment = new OwnTicketsFragment();

        // Set initial properties for HSL Open MaaS Client Library
        // organizationId and clientId must match those used in ticket order or the tickets won't show
        Bundle initialProps = new Bundle();
        initialProps.putString("organizationId", organizationId);
        initialProps.putString("clientId", clientId);
        initialProps.putString("dev", dev);
        fragment.setArguments(initialProps);

        return fragment;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mReactRootView = new ReactRootView(context);
        mReactInstanceManager = ((MainApplication) getActivity().getApplication()).getReactNativeHost().getReactInstanceManager();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) { super.onCreate(savedInstanceState); }

    @Override
    public ReactRootView onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        return mReactRootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mReactRootView.startReactApplication(mReactInstanceManager, "clientlib", getArguments());
    }

    @Override
    public void onDetach() {
        super.onDetach();
    }
}
