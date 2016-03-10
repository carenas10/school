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
        //get list of notes that need to be synced
        Cursor c = AllNotes.getInstance().getDB().rawQuery("SELECT * FROM notes WHERE toSync=1", null);
        int idIndex = c.getColumnIndex("id");
        int toDeleteIndex = c.getColumnIndex("toDelete");

        Log.i("SYNC_UP_CURSOR_COUNT",Integer.toString(c.getCount()));

        //for each note, fetch it
        if(c.getCount() > 0){
            while(c.moveToNext()){
                Note toSync = AllNotes.getInstance().fetchNote(c.getInt(idIndex));

                //update/delete/add depending on what is required
                if(c.getInt(toDeleteIndex) == 0 && toSync.getRemoteID() == 0){
                    //completely new note
                    syncUpAdd(toSync);
                } else if(c.getInt(toDeleteIndex) == 0 && toSync.getRemoteID() != 0){
                    //old note to update on remote
                    syncUpUpdate(toSync);
                } else if(c.getInt(toDeleteIndex) == 1 && toSync.getRemoteID() == 0){
                    //delete note, local only. done after syncUpFinishes
                } else if(c.getInt(toDeleteIndex) == 1 && toSync.getRemoteID() != 0){
                    //delete remote
                    syncUpDelete(toSync);
                } else {
                    Log.e("syncUp","conditions not checked");
                }
            }
        }
    }

    //log in
    public void login(){

    }

    //------------------------ HELPER METHODS ------------------------
    public void syncUpAdd(final Note note){
        if (requestQueue == null) instantiateRequestQueue();

        StringRequest strRequest = new StringRequest(Request.Method.POST, this.baseURL + "notes",
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        Log.i("SYNC_ADD_UP_RESP_DATA",response.toString());
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
                params.put("owner", "1");
                params.put("text", note.getText());
                params.put("created", note.getCreated());
                return params;
            }
        };

        //Log.i("POST REQUEST",postRequest.toString());
        //Log.i("POST REQUEST", postRequest.getBodyContentType());

        this.requestQueue.add(strRequest);
    }

    public void syncUpUpdate(Note note){
        Log.i("SYNC", "SYNC_UP_UPDATE");
    }

    public void syncUpDelete(Note note){
        Log.i("SYNC", "SYNC_UP_DELETE");
    }

    public int toSyncCount(){
        Cursor c = AllNotes.getInstance().getDB().rawQuery("SELECT * FROM notes WHERE toSync=1", null);
        return c.getCount();
    }
}
