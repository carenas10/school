package com.jakedawkins.notes;

import android.content.Intent;
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


    /*!
     *  Launches a new activity for creating a new note
     *
     *  \param view| button clicked
     */
    public void newNote(View view){
        Intent intent = new Intent(this, NewNote.class);
        startActivity(intent);
    }

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
     *  Launches a new activity for searching notes
     *
     *  \param item| button clicked
     */
    public boolean toSearchActivity(MenuItem item){
        Intent intent = new Intent(this, SearchActivity.class);
        startActivity(intent);
        return true;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_notes);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        AllNotes.getInstance().setContext(getApplicationContext());
        RemoteDB.getInstance().setContext(getApplicationContext());

        ///notes table
        ListView listView = (ListView)findViewById(R.id.listView);

        ///load up the db and retrieve notes
        SQLiteDatabase db = this.openOrCreateDatabase("notes", MODE_PRIVATE, null);
        AllNotes.getInstance().setUpDB(db);

        ///delete old notes
        if(RemoteDB.getInstance().toSyncCount() == 0){
            AllNotes.getInstance().deleteAllNotes();
        } else {
            RemoteDB.getInstance().syncUp();
        }

        ///set up note adapter
        adapter = new NoteAdapter(this, this.notes);

        //syncDown must be called after adapter is set
        RemoteDB.getInstance().syncDown(adapter);

        ///link adapter to listView
        listView.setAdapter(adapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(ListNotes.this, EditNote.class);
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
        //Log.i("RESUME","SYNC UP CALLED");
        //RemoteDB.getInstance().syncUp();
    }
}