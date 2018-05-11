package com.example.hsl_openmaas.exampleappandroid;

import android.content.Context;
import android.os.Bundle;
import android.provider.Settings.Secure;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.NetworkError;
import com.android.volley.NoConnectionError;
import com.android.volley.ParseError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.RetryPolicy;
import com.android.volley.ServerError;
import com.android.volley.TimeoutError;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BuyTicketFragment extends Fragment {
    public BuyTicketFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_buy_ticket, container, false);

        // Implement datetime picker when available in API
        Spinner validFromSpinner= view.findViewById(R.id.validFromSpinner);
        ArrayAdapter<CharSequence> validFromAdapter = ArrayAdapter.createFromResource(getActivity(),
                R.array.valid_from, R.layout.single_spinner_item);
        validFromAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        validFromSpinner.setEnabled(false);
        validFromSpinner.setClickable(false);
        validFromSpinner.setAdapter(validFromAdapter);

        // Implement your own paymentType selector here if you need to
        Spinner paymentTypeSpinner = view.findViewById(R.id.paymentTypeSpinner);
        ArrayAdapter<CharSequence> paymentTypeAdapter = ArrayAdapter.createFromResource(getActivity(),
                R.array.payment_types, R.layout.single_spinner_item);
        paymentTypeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        paymentTypeSpinner.setEnabled(false);
        paymentTypeSpinner.setClickable(false);
        paymentTypeSpinner.setAdapter(paymentTypeAdapter);

        /*
         * Get ticket, region and customer types from HSL endpoints.
         *
         * In the future, there can be cases where selecting a value for an attribute rules out
         * the possibility of selecting something else. For example if a user has selected the
         * value child as the customerType-attribute, it rules out the possibility of selecting
         * the value period as the ticketType-attribute.
         *
         * See more here: https://sales-api.hsl.fi/public-docs
         */
        String[] choices = {}; // For ruling out selections when API supports it.
        final Spinner ticketTypeSpinner = view.findViewById(R.id.ticketTypeSpinner);
        this.fetchSpinnerData("https://sales-api.hsl.fi/api/sandbox/ticket/v1/getTicketTypes", choices, ticketTypeSpinner);
        final Spinner customerTypeSpinner = view.findViewById(R.id.customerTypeSpinner);
        this.fetchSpinnerData("https://sales-api.hsl.fi/api/sandbox/ticket/v1/getCustomerTypes", choices, customerTypeSpinner);
        final Spinner regionTypeSpinner = view.findViewById(R.id.regionTypeSpinner);
        this.fetchSpinnerData("https://sales-api.hsl.fi/api/sandbox/ticket/v1/getRegions", choices, regionTypeSpinner);

        final Button buyTicketButton = view.findViewById(R.id.buyTicketButton);
        final ProgressBar buyTicketProgressBar = view.findViewById(R.id.progressBar);
        buyTicketButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Map<String, String> params = new HashMap<String, String>();

                String deviceId = Secure.getString(getActivity().getApplicationContext().getContentResolver(), Secure.ANDROID_ID);

                params.put("clientId", "MaaSOperatorAssignedUniqueId");
                params.put("deviceId", deviceId);

                SpinnerData ticketType = (SpinnerData) ticketTypeSpinner.getSelectedItem();
                params.put("ticketTypeId", ticketType.id);

                SpinnerData customerType = (SpinnerData) customerTypeSpinner.getSelectedItem();
                params.put("customerTypeId", customerType.id);

                SpinnerData regionType = (SpinnerData) regionTypeSpinner.getSelectedItem();
                params.put("regionId", regionType.id);

                // Send user phone number also so it can be used to check ticket validity if phone battery runs out.
                // You can either automatically fill this or create some ui element for it.
                params.put("phoneNumber", "+358 12 234 1234");

                BuyTicketFragment.this.purchaseTicket(params, buyTicketButton, buyTicketProgressBar);
            }
        });

        return view;
    }

    private void fetchSpinnerData(String endpoint, String [] choices, final Spinner spinner) {
        spinner.setEnabled(false);
        spinner.setClickable(false);

        StringRequest request = new StringRequest(Request.Method.POST, endpoint, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                try {
                    JSONArray data = new JSONArray(response);

                    List<SpinnerData> spinnerDataList = new ArrayList<>();

                    for (int i = 0; i<data.length(); i++){
                        String id = data.getJSONObject(i).getString("id");
                        String description = data.getJSONObject(i).getString("description");
                        String displayName = data.getJSONObject(i).getString("displayName");

                        spinnerDataList.add(new SpinnerData(id, description, displayName));
                    }

                    CustomAdapter adapter = new CustomAdapter(spinnerDataList);
                    spinner.setAdapter(adapter);
                } catch (JSONException e) {
                    // Handle error here
                    Log.i("error", e.toString());
                }

                spinner.setEnabled(true);
                spinner.setClickable(true);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                // Handle error here
                spinner.setEnabled(true);
                spinner.setClickable(true);
            }
        });

        RequestQueue queue = Volley.newRequestQueue(getActivity().getApplicationContext());
        queue.add(request);
    }

    private void purchaseTicket (Map<String, String> params, final Button button, final ProgressBar progressBar) {
        button.setClickable(false);
        button.setEnabled(false);
        progressBar.setVisibility(View.VISIBLE);

        /*
         * Your own server endpoint
         *
         * You need to add the X-API-Key header on your own server and probably also charge the customer before actually
         * buying the ticket from HSL API.
         *
         * To get started quickly, you can use HSL example server that can be found in GitHub /example/server folder.
         *
         * *** DO NOT *** add the API Key to your mobile app!
         */
        String endpoint = "http://10.0.2.2:3000/order";

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, endpoint, new JSONObject(params), new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject response) {
                Toast.makeText(
                    getActivity().getApplicationContext(),
                    "Lipun osto onnistui! Näet lippusi päivittämällä 'Omat liput' näkymän.",
                    Toast.LENGTH_LONG
                ).show();

                button.setClickable(true);
                button.setEnabled(true);
                progressBar.setVisibility(View.INVISIBLE);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.i("error", error.toString());
                if (error instanceof TimeoutError) {
                    Toast.makeText(
                            getActivity().getApplicationContext(),
                            "Yhteys aikakatkaistiin",
                            Toast.LENGTH_LONG
                    ).show();
                } else if (error instanceof AuthFailureError) {
                    Toast.makeText(
                            getActivity().getApplicationContext(),
                            "Tunnistautuminen epäonnistui",
                            Toast.LENGTH_LONG
                    ).show();
                } else if (error instanceof ServerError) {
                    Toast.makeText(
                            getActivity().getApplicationContext(),
                            "Pavelinvirhe",
                            Toast.LENGTH_LONG
                    ).show();
                } else if (error instanceof NetworkError || error instanceof NoConnectionError) {
                    Toast.makeText(
                            getActivity().getApplicationContext(),
                            "Yhteysvirhe",
                            Toast.LENGTH_LONG
                    ).show();
                } else if (error instanceof ParseError) {
                    Toast.makeText(
                            getActivity().getApplicationContext(),
                            "Virhe",
                            Toast.LENGTH_LONG
                    ).show();
                }

                button.setClickable(true);
                button.setEnabled(true);
                progressBar.setVisibility(View.INVISIBLE);
            }
        }) {
            @Override
            public String getBodyContentType() {
                return "application/json; charset=utf-8";
            }
        };

        RequestQueue queue = Volley.newRequestQueue(getActivity().getApplicationContext());

        // Set bit longer timeout period for sandbox api
        int timeout = 60000;
        RetryPolicy policy = new DefaultRetryPolicy(timeout, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT);
        request.setRetryPolicy(policy);

        queue.add(request);
    }

    @Override
    public void onDetach() {
        super.onDetach();
    }

    private class CustomAdapter extends BaseAdapter implements SpinnerAdapter {
        private final List<SpinnerData> data;

        public CustomAdapter(List<SpinnerData> data){
            this.data = data;
        }

        @Override
        public int getCount() {
            return data.size();
        }

        @Override
        public Object getItem(int position) {
            return data.get(position);
        }

        @Override
        public long getItemId(int i) {
            return i;
        }

        @Override
        public View getView(int position, View recycle, ViewGroup parent) {
            TextView view;
            if (recycle != null){
                // Re-use the recycled view here!
                view = (TextView) recycle;
            } else {
                // No recycled view, inflate the "original" from the platform:
                view = (TextView) getLayoutInflater().inflate(
                        R.layout.single_spinner_item, parent, false
                );
            }

            view.setText(data.get(position).displayName);
            return view;
        }
    }

    private class SpinnerData {
        private final String id;
        private final String description;
        private final String displayName;

        public SpinnerData(String id, String description, String displayName){
            this.id = id;
            this.description = description;
            this.displayName = displayName;
        }

        public String getId() {
            return id;
        }

        public String getDescription() {
            return description;
        }

        public String getDisplayName() {
            return displayName;
        }
    }
}
