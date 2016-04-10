package com.jakedawkins.notes;

import android.content.Context;
import android.database.Cursor;
import android.util.Log;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/*!
 * Created by jake on 3/8/16.
 * class for making remote API calls
 */
public class RemoteDB {

    private RequestQueue requestQueue;
    private static final RemoteDB remoteDB = new RemoteDB();
    private Context context;
    private String baseURL = "http://thrownote.com/api/v1/";
    private String username;
    private String password;
    private int userID;
    private boolean loggedIn = false;

    /*!
     *  Singleton instance of this class
     *  \return allNotes| class variable
     */
    public static RemoteDB getInstance(){
        return remoteDB;
    }

    //------------------------ GETTERS ------------------------

    public String getUsername(){
        return this.username;
    }

    public int getUserID(){
        return this.userID;
    }

    public boolean loggedIn(){
        return this.loggedIn;
    }

    public RequestQueue getRequestQueue(){ return this.requestQueue; }

    public String getBaseURL(){ return this.baseURL; }

    //------------------------ SETTERS ------------------------
    public void setUsername(String username){ this.username = username; }

    public void setPassword(String password){ this.password = password; }

    public void setUserID(int userID){ this.userID = userID; }

    public void setContext(Context context){ this.context = context; }

    public void instantiateRequestQueue(){ requestQueue = Volley.newRequestQueue(this.context); }

    //------------------------ API CALLS ------------------------

    //load notes from remote
    public void syncDown(final NoteAdapter adapter){
        if (requestQueue == null) instantiateRequestQueue();

        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.GET,this.baseURL + "users/" + userID + "/notes",null,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        try {
                            /// convert data section of response to array of json objects
                            JSONArray jsonArray = response.getJSONArray("data");

                            /// parse each note
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

    /// sync notes from local
    public void syncUp(){
        /// get list of notes that need to be synced
        Cursor c = AllNotes.getInstance().getDB().rawQuery("SELECT * FROM notes WHERE toSync=1", null);
        int idIndex = c.getColumnIndex("id");
        int toDeleteIndex = c.getColumnIndex("toDelete");

        Log.i("SYNC_UP_CURSOR_COUNT",Integer.toString(c.getCount()));

        /// for each note, fetch it
        if(c.getCount() > 0){
            while(c.moveToNext()){
                Note toSync = AllNotes.getInstance().fetchNote(c.getInt(idIndex));

                /// update/delete/add depending on what is required
                if(c.getInt(toDeleteIndex) == 0 && toSync.getRemoteID() == 0){
                    /// completely new note
                    Log.i("SYNC_UP","NEW NOTE");
                    syncUpAdd(toSync);
                } else if(c.getInt(toDeleteIndex) == 0 && toSync.getRemoteID() != 0){
                    /// old note to update on remote
                    Log.i("SYNC_UP","UPDATE NOTE");
                    syncUpUpdate(toSync);
                } /*else if(c.getInt(toDeleteIndex) == 1 && toSync.getRemoteID() == 0){
                    /// delete note, local only. done after syncUpFinishes
                }*/ else if(c.getInt(toDeleteIndex) == 1 && toSync.getRemoteID() != 0){
                    /// delete remote
                    Log.i("SYNC_UP","DELETE NOTE");
                    syncUpDelete(toSync);
                } else {
                    Log.e("syncUp","conditions not checked");
                }
            }
        }
        c.close();
        AllNotes.getInstance().deleteMarkedNotes();
    }

    /// log in. sends username and password to API.
    /// API returns json description of user if correct login
    public void login(){
        if (requestQueue == null) instantiateRequestQueue();

        StringRequest strRequest = new StringRequest(Request.Method.POST, this.baseURL + "users/" + this.username,
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        Log.i("LOGIN_RESPONSE",response);
                        try {
                            JSONObject responseJSON = new JSONObject(response);

                            boolean success = responseJSON.getJSONObject("data").getBoolean("login");
                            if(success){
                                userID = responseJSON.getJSONObject("data").getInt("id");
                                loggedIn = true;
                                Log.i("LOGIN_RESPONSE_ID","user id from response: " + userID);
                            }
                        } catch(JSONException e){
                            Log.i("ERROR PARSING JSON", "TRUE");
                        }
                    }
                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        Log.i("LOGIN_ERROR","TRUE");
                    }
                })
        {
            @Override
            protected Map<String, String> getParams()
            {
                Map<String, String> params = new HashMap<String, String>();
                params.put("username", username);
                params.put("password", password);
                return params;
            }
        };

        this.requestQueue.add(strRequest);
    }

    /*
    public void newUser(){
        if (requestQueue == null) instantiateRequestQueue();

        StringRequest strRequest = new StringRequest(Request.Method.POST, this.baseURL + "users",
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        Log.i("LOGIN_RESPONSE",response);
                        try {
                            JSONObject responseJSON = new JSONObject(response);

                            boolean success = responseJSON.getJSONObject("data").getBoolean("login");
                            if(success){
                                userID = responseJSON.getJSONObject("data").getInt("id");
                                loggedIn = true;
                                Log.i("LOGIN_RESPONSE_ID","user id from response: " + userID);
                            }
                        } catch(JSONException e){
                            Log.i("ERROR PARSING JSON", "TRUE");
                        }
                    }
                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        Log.i("LOGIN_ERROR","TRUE");
                    }
                })
        {
            @Override
            protected Map<String, String> getParams()
            {
                Map<String, String> params = new HashMap<String, String>();
                params.put("username", username);
                params.put("password", password);
                return params;
            }
        };

        this.requestQueue.add(strRequest);
    }*/

    public void logOut(){
        username = "";
        password = "";
        userID = -1;
        loggedIn = false;
    }

    //------------------------ HELPER METHODS ------------------------
    /// adds a new note to the remote DB
    public void syncUpAdd(final Note note){
        if (requestQueue == null) instantiateRequestQueue();

        StringRequest strRequest = new StringRequest(Request.Method.POST, this.baseURL + "notes",
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        Log.i("SYNC_ADD_UP_RESP_DATA",response);
                        try {
                            JSONObject responseJSON = new JSONObject(response);
                            int remoteID =responseJSON.getJSONObject("data").getInt("id");
                            Log.i("REMOTE ID FROM REQUEST", Integer.toString(remoteID));

                            note.setRemoteID(remoteID);
                            note.setToSync(0);
                            AllNotes.getInstance().updateNote(note);

                        } catch(JSONException e){
                            Log.i("ERROR PARSING JSON", "TRUE");
                        }
                    }
                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        Log.i("SYNC_UP_ADD_ERROR","TRUE");
                    }
                })
        {
            @Override
            protected Map<String, String> getParams()
            {
                Map<String, String> params = new HashMap<String, String>();
                params.put("owner", Integer.toString(userID));
                params.put("text", note.getText());
                params.put("created", note.getCreated());
                return params;
            }
        };

        this.requestQueue.add(strRequest);
    }

    /// updates a note in the remote db
    public void syncUpUpdate(final Note note){
        if (requestQueue == null) instantiateRequestQueue();

        StringRequest strRequest = new StringRequest(Request.Method.POST, this.baseURL + "notes/" + note.getRemoteID(),
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        Log.i("SYNC_UP_UPD_RESP_DATA",response);
                        note.setToSync(0);
                        AllNotes.getInstance().updateNote(note);
                    }
                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        Log.i("SYNC_UP_UPD_ERROR","TRUE");
                    }
                })
        {
            @Override
            protected Map<String, String> getParams()
            {
                Map<String, String> params = new HashMap<String, String>();
                params.put("owner", Integer.toString(userID));
                params.put("text", note.getText());
                params.put("created", note.getCreated());
                params.put("updated",note.getUpdated());
                return params;
            }
        };

        this.requestQueue.add(strRequest);
    }

    /// deletes a note in the remote DB
    public void syncUpDelete(final Note note){
        if (requestQueue == null) instantiateRequestQueue();

        Log.i("SYNC_UP_DEL_ID", Integer.toString(note.getRemoteID()));
        StringRequest strRequest = new StringRequest(Request.Method.DELETE, this.baseURL + "notes/" + note.getRemoteID(),
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        Log.i("SYNC_UP_DEL_RESP_DATA",response);
                        note.setToSync(0);
                        AllNotes.getInstance().updateNote(note);
                    }
                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        Log.i("SYNC_UP_DEL_ERROR","TRUE");
                    }
                });

        this.requestQueue.add(strRequest);
    }

    /// count of notes that need syncing
    public int toSyncCount(){
        Cursor c = AllNotes.getInstance().getDB().rawQuery("SELECT * FROM notes WHERE toSync=1", null);
        int count = c.getCount();
        c.close();
        return count;
    }
}
