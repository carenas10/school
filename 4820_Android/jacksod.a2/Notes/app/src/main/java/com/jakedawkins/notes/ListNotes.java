package com.jakedawkins.notes;

import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import com.jakedawkins.notes.Note;

import java.util.ArrayList;

public class ListNotes extends AppCompatActivity {

    //get singleton notes list
    ArrayList<Note> notes = AllNotes.getInstance().getNotes();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_notes);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });

        //sample data
        Note note1 = new Note(); Note note2 = new Note(); Note note3 = new Note();
        note1.setText("test1"); note2.setText("test2"); note3.setText("test3");
        note1.addTag("tag1"); note1.addTag("tag2"); note1.addTag("tag3");
        note2.addTag("tag1"); note2.addTag("tag2");
        note3.addTag("tag1");
        notes.add(note1); notes.add(note2); notes.add(note3);

        //fill notes table
        ListView listView = (ListView)findViewById(R.id.listView);

        //set up note adapter
        NoteAdapter adapter = new NoteAdapter(this, notes);

        //link adapter to listView
        listView.setAdapter(adapter);

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_list_notes, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
