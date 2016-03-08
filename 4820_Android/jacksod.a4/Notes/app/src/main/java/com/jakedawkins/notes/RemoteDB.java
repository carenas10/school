package com.jakedawkins.notes;

import android.content.Context;
import android.util.Log;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/*!
 * Created by jake on 3/8/16.
 * class for making remote API calls
 */
public class RemoteDB {

    private RequestQueue requestQueue;
    private static final RemoteDB remoteDB = new RemoteDB();
    private Context context;
    private String baseURL = "http://thrownote.com/api/v1/";

    /*!
     *  Singleton instance of this class
     *  \return allNotes| class variable
     */
    public static RemoteDB getInstance(){
        return remoteDB;
    }

    //------------------------ GETTERS ------------------------


    //------------------------ SETTERS ------------------------
    public void setContext(Context context){
        this.context = context;
    }

    public void instantiateRequestQueue(){
        requestQueue = Volley.newRequestQueue(this.context);
    }

    //------------------------ API CALLS ------------------------
    public void test(){
        if (requestQueue == null) instantiateRequestQueue();

        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.GET,this.baseURL + "users/1/notes",null,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        try {
                            JSONArray jsonArray = response.getJSONArray("data");
                            Log.i("jsonArray:", jsonArray.toString(4));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.e("Error: ", error.getMessage());
            }
        });

        this.requestQueue.add(jsonObjectRequest);
    }

    //check server status

    //load notes from remote

    //sync notes from local

    //log in
}
