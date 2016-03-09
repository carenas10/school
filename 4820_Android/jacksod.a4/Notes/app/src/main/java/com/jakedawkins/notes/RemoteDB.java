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

    //load notes from remote
    public void syncDown(final NoteAdapter adapter){
        if (requestQueue == null) instantiateRequestQueue();

        Log.i("METHOD","syncDown Called");

        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.GET,this.baseURL + "users/1/notes",null,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        try {
                            ///convert data section of response to array of json objects
                            JSONArray jsonArray = response.getJSONArray("data");

                            ///parse each note
                            for(int i=0; i<jsonArray.length(); i++){
                                JSONObject JSONNote = jsonArray.getJSONObject(i);

                                String text = JSONNote.getString("text");
                                String updated = JSONNote.getString("updated");
                                String created = JSONNote.getString("created");
                                int remoteID = JSONNote.getInt("id");

                                Note newNote = new Note();
                                newNote.setText(text);
                                newNote.setCreated(created);
                                newNote.setUpdated(updated);
                                newNote.setRemoteID(remoteID);

                                AllNotes.getInstance().addNewNote(newNote);

                                //Log.i("NOTE",text + ", " + created + ", " + updated + ", " + remoteID);
                            }
                            
                            if(adapter != null){
                                adapter.notifyDataSetChanged();
                            }
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

    //sync notes from local
    public void syncUp(){

    }

    //log in
    public void login(){

    }
}
