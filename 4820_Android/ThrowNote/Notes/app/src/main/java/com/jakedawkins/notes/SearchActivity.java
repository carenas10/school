package com.jakedawkins.notes;

import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;

public class SearchActivity extends AppCompatActivity {

    ArrayList<Note> notes = AllNotes.getInstance().getNotes();
    Note noResults = new Note();
    NoteAdapter adapter;

    //------------------------ SEARCH METHODS ------------------------
    /*!
     *  Used to find the notes
     *  Basic search by text
     */
    public void search(){
        EditText searchBox = (EditText)findViewById(R.id.searchBox);
        String query = searchBox.getText().toString().replaceAll("'","''");

        /// c identifies tags (priority)
        Cursor c = AllNotes.getInstance().getDB().rawQuery("SELECT DISTINCT notes.id FROM notes JOIN tags_notes ON notes.id=tags_notes.note_id JOIN tags ON tags.id=tags_notes.tag_id WHERE notes.textContent LIKE '%" + query + "%' OR tags.name LIKE '%" + query + "%' ORDER BY notes.id DESC", null);
        /// c2 identifies note text content
        Cursor c2 = AllNotes.getInstance().getDB().rawQuery("SELECT DISTINCT id FROM notes WHERE textContent LIKE '%" + query + "%' ORDER BY notes.id DESC", null);

        int idIndex = c.getColumnIndex("id");
        int idIndex2 = c2.getColumnIndex("id");
        HashSet<Integer> indices = new HashSet<Integer>();

        if(c.getCount() > 0 || c2.getCount() > 0) {
            if(c.getCount() > 0){
                for (c.moveToFirst(); !c.isAfterLast(); c.moveToNext()) {
                    indices.add(c.getInt(idIndex));
                }
            }
            if(c2.getCount() > 0){
                for (c2.moveToFirst(); !c2.isAfterLast(); c2.moveToNext()) {
                    indices.add(c2.getInt(idIndex2));
                }
            }

            notes.clear();

            Iterator<Integer> i = indices.iterator();
            while (i.hasNext()) {
                int id = i.next();
                Note newNote = AllNotes.getInstance().fetchNote(id);
                notes.add(newNote);
            }
        } else { /// no notes found
            notes.clear();
            notes.add(noResults);
        }

        c.close();
        c2.close();

        adapter.notifyDataSetChanged();
    }

    /*
    *   user hit recent button
    *   searches notes made in the last 3 days
    */
    public void searchRecent(View view){
        Cursor c = AllNotes.getInstance().getDB().rawQuery("SELECT * FROM notes WHERE `created` LIKE '" + nowShort() + "%'", null);

        int idIndex = c.getColumnIndex("id");
        HashSet<Integer> indices = new HashSet<Integer>();

        if(c.getCount() > 0) {
            if(c.getCount() > 0){
                for (c.moveToFirst(); !c.isAfterLast(); c.moveToNext()) {
                    indices.add(c.getInt(idIndex));
                }
            }

            notes.clear();

            Iterator<Integer> i = indices.iterator();
            while (i.hasNext()) {
                int id = i.next();
                Note newNote = AllNotes.getInstance().fetchNote(id);
                notes.add(newNote);
            }
        } else { /// no notes found
            notes.clear();
            notes.add(noResults);
        }

        c.close();

        adapter.notifyDataSetChanged();
    }

    /*
    *   user hit photo button
    *   searches notes with photos
    */
    public void searchPhotos(View view){
        Cursor c = AllNotes.getInstance().getDB().rawQuery("SELECT DISTINCT note_id FROM attachments WHERE filetype_id=" + AllNotes.getFiletypeID("png"), null);

        int idIndex = c.getColumnIndex("note_id");
        HashSet<Integer> indices = new HashSet<Integer>();

        if(c.getCount() > 0) {
            if(c.getCount() > 0){
                for (c.moveToFirst(); !c.isAfterLast(); c.moveToNext()) {
                    indices.add(c.getInt(idIndex));
                }
            }

            notes.clear();

            Iterator<Integer> i = indices.iterator();
            while (i.hasNext()) {
                int id = i.next();
                Note newNote = AllNotes.getInstance().fetchNote(id);
                notes.add(newNote);
            }
        } else { /// no notes found
            notes.clear();
            notes.add(noResults);
        }

        c.close();

        adapter.notifyDataSetChanged();
    }

    /*
    *   user hit audio button
    *   searches notes with audio attachments
    */
    public void searchAudio(View view){
        Cursor c = AllNotes.getInstance().getDB().rawQuery("SELECT DISTINCT note_id FROM attachments WHERE filetype_id=" + AllNotes.getFiletypeID("mp3"), null);

        int idIndex = c.getColumnIndex("note_id");
        HashSet<Integer> indices = new HashSet<Integer>();

        if(c.getCount() > 0) {
            if(c.getCount() > 0){
                for (c.moveToFirst(); !c.isAfterLast(); c.moveToNext()) {
                    indices.add(c.getInt(idIndex));
                }
            }

            notes.clear();

            Iterator<Integer> i = indices.iterator();
            while (i.hasNext()) {
                int id = i.next();
                Note newNote = AllNotes.getInstance().fetchNote(id);
                notes.add(newNote);
            }
        } else { /// no notes found
            notes.clear();
            notes.add(noResults);
        }

        c.close();

        adapter.notifyDataSetChanged();
    }

    /*
    *   user hit bookmarks button
    *   searches notes with bookmark links
    */
    public void searchBookmark(){

    }

    //------------------------ UI METHODS ------------------------

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        EditText searchBox = (EditText)findViewById(R.id.searchBox);
        searchBox.addTextChangedListener(textWatcher);

        ///to be shown if there are no results
        noResults.setText("0 Results. Search by text or tags");

        notes.clear();
        notes.add(0, noResults); //initially no results

        /// Get a support ActionBar corresponding to this toolbar
        ActionBar ab = getSupportActionBar();

        /// Enable the Up button
        if (ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }

        /// fill notes table
        ListView listView = (ListView)findViewById(R.id.searchListView);

        /// set up note adapter
        adapter = new NoteAdapter(this, notes);

        /// link adapter to listView
        listView.setAdapter(adapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(SearchActivity.this, ViewNoteActivity.class);
                AllNotes.getInstance().setEditIndex(position);
                startActivity(intent);
            }
        });
    }

    //------------------------ HELPER METHODS ------------------------

    private TextWatcher textWatcher = new TextWatcher() {
        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) { search(); }

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) { }

        @Override
        public void afterTextChanged(Editable s) { }
    };


    /*!
     *  Used to generate a mySQL-like timedate string of right now
     *  in format of YYYY-MM-DD HH:MM:SS
     *
     *  \return String| current timeDate string
     */
    public String now(){
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date date = new Date();
        return dateFormat.format(date); //2014-08-06 15:59:48
    }

    /*!
     *  Used to generate a mySQL-like timedate string of right now
     *  in format of YYYY-MM-DD HH:MM:SS
     *
     *  \return String| current timeDate string
     */
    public String nowShort(){
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date date = new Date();
        return dateFormat.format(date); //2014-08-06
    }
}
