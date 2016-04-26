package com.jakedawkins.notes;

import android.content.Context;
import android.database.Cursor;
import android.os.AsyncTask;
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

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
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
                //Log.e("Error: ", error.getMessage());
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
    }

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

                            //check if there is an attachment to upload
                            if(note.getPath() != null){
                                if(note.getFiletype().equals("png")){
                                    new UploadFileTask().execute(new FileParams(note.getPath(), note.getRemoteID(), "photo"));
                                } else {
                                    new UploadFileTask().execute(new FileParams(note.getPath(), note.getRemoteID(), "audio"));
                                }
                            }

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

                        //first delete old attachments
                        fileDelete(note);

                        //check if there is an attachment to upload
                        if(note.getPath() != null){
                            if(note.getFiletype().equals("png")){
                                new UploadFileTask().execute(new FileParams(note.getPath(), note.getRemoteID(), "photo"));
                            } else {
                                new UploadFileTask().execute(new FileParams(note.getPath(), note.getRemoteID(), "audio"));
                            }
                        }

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

        //delete attachments first
        fileDelete(note);

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

    //------------------------ File Uploading Methods ------------------------
    private class FileParams {
        public String path;
        public int remoteID;
        public String type;

        FileParams(String path, int remoteID, String type){
            this.path = path;
            this.remoteID = remoteID;
            this.type = type;
        }
    }

    private class UploadFileTask extends AsyncTask<FileParams, Void, String> {
        @Override
        protected String doInBackground(FileParams... params) {
            return uploadFile(params[0].path, params[0].remoteID, params[0].type);
        }
    }

    //Uploads a local file to a server
    public String uploadFile(final String path, int noteID, String type) {
        String ret="0";

        String fileName = path;
        HttpURLConnection conn = null;
        DataOutputStream dos = null;
        //Separators for the post data
        String lineEnd = "\r\n";
        String twoHyphens = "--";
        String boundary = "*****";
        int bytesRead, bytesAvailable, bufferSize;
        byte[] buffer;
        int maxBufferSize = 1024 * 1024;
        File sourceFile = new File(path);
        Log.i("FILE",sourceFile.getName());

        try {
            FileInputStream fileInputStream = new FileInputStream(sourceFile);
            //The php script
            URL url = new URL("http://thrownote.com/api/v1/notes/" + noteID + "/file");
            conn = (HttpURLConnection) url.openConnection();
            conn.setDoInput(true);
            conn.setDoOutput(true);
            conn.setUseCaches(false);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Connection", "Keep-Alive");
            conn.setRequestProperty("Content-Type", "multipart/form-data;boundary=" + boundary);
            conn.setRequestProperty(type, fileName);

            //Boundary
            dos = new DataOutputStream(conn.getOutputStream());
            dos.writeBytes(twoHyphens + boundary + lineEnd);

            //$_FILE['uploaded_file']
            //type -- photo or audio
            dos.writeBytes("Content-Disposition: form-data; name=\"" + type + "\";filename=\"" + fileName + "\"" + lineEnd);
            dos.writeBytes(lineEnd);
            bytesAvailable = fileInputStream.available();
            bufferSize = Math.min(bytesAvailable, maxBufferSize);
            buffer = new byte[bufferSize];
            bytesRead = fileInputStream.read(buffer, 0, bufferSize);
            while (bytesRead > 0) {
                dos.write(buffer, 0, bufferSize);
                bytesAvailable = fileInputStream.available();
                bufferSize = Math.min(bytesAvailable, maxBufferSize);
                bytesRead = fileInputStream.read(buffer, 0, bufferSize);
            }

            //Boundary
            dos.writeBytes(lineEnd);
            dos.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);

            int serverResponseCode = conn.getResponseCode();
            //Good return
            if (serverResponseCode == 200 || serverResponseCode==201) {
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String line = br.readLine();
                //The php script either returns a url or 0 if the upload failed
                ret=line;
            }

            fileInputStream.close();
            dos.flush();
            dos.close();

            //Return the result to our activity
            Log.i("FILE RET", ret);
            return ret;

        } catch (MalformedURLException ex) {
            Log.i("FILE MALFORMED ERR RET", ret);
            Log.e("Exeption", ex.toString());
            return ret;
        } catch (final Exception e) {
            Log.i("FILE ERR RET", ret);
            Log.e("Exeption", e.toString());
            return ret;
        }
    }

    /// deletes a note in the remote DB
    public void fileDelete(final Note note){
        if (requestQueue == null) instantiateRequestQueue();

        Log.i("DEL_FILE", Integer.toString(note.getRemoteID()));
        StringRequest strRequest = new StringRequest(Request.Method.DELETE, this.baseURL + "notes/" + note.getRemoteID() + "/file",
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        Log.i("DEL_FILE_RESP_DATA",response);
                        note.setToSync(0);
                        AllNotes.getInstance().updateNote(note);
                    }
                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        Log.i("DEL_FILE_ERROR","TRUE");
                    }
                });

        this.requestQueue.add(strRequest);
    }
}
