package com.jakedawkins.notes;

import android.content.Intent;
import android.content.SharedPreferences;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.Menu;
import android.widget.AdapterView;
import android.widget.ListView;
import java.util.ArrayList;


public class ListNotes extends AppCompatActivity {

    ArrayList<Note> notes = AllNotes.getInstance().getNotes();
    public NoteAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.i("LIFECYCLE","CREATE");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_notes);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        AllNotes.getInstance().setContext(getApplicationContext());
        RemoteDB.getInstance().setContext(getApplicationContext());

        /// notes table
        ListView listView = (ListView)findViewById(R.id.listView);

        /// load up the db
        SQLiteDatabase db = this.openOrCreateDatabase("notes", MODE_PRIVATE, null);
        AllNotes.getInstance().setUpDB(db);

        /// check if user is logged in
        SharedPreferences settings = getSharedPreferences("UserInfoPrefs", 0);
        int userID = settings.getInt("userID", -1);
        if(userID == -1){ //not logged in. Redirect to login page
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);
        } else {
            //logged in user. set user id on the remote DB class for MySQL Queries
            RemoteDB.getInstance().setUserID(userID);
        }

        /// set up note adapter
        adapter = new NoteAdapter(this, this.notes);

        /// syncDown must be called after adapter is set
        AllNotes.getInstance().deleteAllNotes();
        RemoteDB.getInstance().syncDown(adapter);

        /// link adapter to listView
        listView.setAdapter(adapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(ListNotes.this, ViewNoteActivity.class);
                AllNotes.getInstance().setEditIndex(position);
                startActivity(intent);
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        /// Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_list_notes, menu);
        return true;
    }


    /*!
     *  gets called whenever a user leaves the view (to another app/view)
     */
    @Override
    public void onResume(){
        super.onResume();
        adapter.notifyDataSetChanged();
        //AllNotes.getInstance().deleteAllNotes();
        //RemoteDB.getInstance().syncDown(adapter);
    }

    //------------------------ MENUBAR ACTION METHODS ------------------------

    /*!
     *  Launches a new activity for viewing information
     *
     *  \param item| button clicked
     */
    public boolean toInfoActivity(MenuItem item){
        Intent intent = new Intent(this, InfoActivity.class);
        startActivity(intent);
        return true;
    }

    /*!
     *  Logs a user out by resetting DB class id and name and removing app prefs
     *
     *  \param item | button clicked
     */
    public boolean logUserOut(MenuItem item){
        SharedPreferences settings = getSharedPreferences("UserInfoPrefs", 0);

        /// We need an Editor object to make preference changes.
        SharedPreferences.Editor editor = settings.edit();
        editor.putInt("userID", -1);
        editor.commit();

        RemoteDB.getInstance().logOut();

        Intent intent = new Intent(this, LoginActivity.class);
        startActivity(intent);

        return true;
    }

    /*!
     *  Launches a new activity for searching notes
     *
     *  \param item| button clicked
     */
    public boolean toSearchActivity(MenuItem item){
        Intent intent = new Intent(this, SearchActivity.class);
        startActivity(intent);
        return true;
    }

    /*!
     *  syncs up then down, and reloads list
     *
     *  \param item| button clicked
     */
    public void refresh(MenuItem item){
        /// delete old notes
        if(RemoteDB.getInstance().toSyncCount() == 0){
            AllNotes.getInstance().deleteAllNotes();
        } else {
            //RemoteDB.getInstance().syncUp();
            AllNotes.getInstance().deleteAllNotes();
        }
        //RemoteDB.getInstance().syncDown(adapter);
    }

    //------------------------ ADDITIONAL ACTION METHODS ------------------------

    /*!
     *  Launches a new activity for creating a new note
     *
     *  \param view| button clicked
     */
    public void newNote(View view){
        Intent intent = new Intent(this, NewNote.class);
        startActivity(intent);
    }

}