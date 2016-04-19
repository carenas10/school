package com.jakedawkins.notes;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.io.IOException;

public class ViewNoteActivity extends AppCompatActivity {

    private Note note;
    TextView textContent;
    TextView characterCount;
    ImageView viewNoteImage;

    public void toEditActivity(View view){
        Intent intent = new Intent(this, EditNote.class);
        startActivity(intent);
    }

    /*!
     *  takes an already existing note and removes it from List and DB
     *
     *  \param View | button pressed
     */
    public void deletePressed(View view) {
        new AlertDialog.Builder(this)
                .setTitle("Delete Note")
                .setMessage("Are you sure you want to delete this note")
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        RemoteDB.getInstance().syncUpDelete(note);
                        AllNotes.getInstance().deleteNote(note);
                    AllNotes.getInstance().deleteMarkedNotes();
                        finish();
                    }
                })
                .setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // do nothing
                }
            })
            .setIcon(android.R.drawable.ic_dialog_alert)
            .show();
    }

    View.OnClickListener playListener = new View.OnClickListener() {
        public void onClick(View v) {
            Log.i("PLAY", "CLICKED");

            MediaPlayer m = new MediaPlayer();

            try { m.setDataSource(note.getPath()); }

            catch (IOException e) {e.printStackTrace();}

            try { m.prepare(); }

            catch (IOException e) { e.printStackTrace(); }

            m.start();
            Toast.makeText(getApplicationContext(), "Playing audio", Toast.LENGTH_LONG).show();
        }
    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_note);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        if(getSupportActionBar() != null){
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        textContent = (TextView)findViewById(R.id.viewNoteTextContent);
        characterCount = (TextView)findViewById(R.id.viewNoteCharacterCount);
        viewNoteImage = (ImageView)findViewById(R.id.viewNoteImage);

        note = AllNotes.getInstance().getNotes().get(AllNotes.getInstance().getEditIndex());

        /// set up text
        textContent.setText(note.getText());

        /// set up character count
        characterCount.setText(String.valueOf(note.getText().length()));
        if(note.getText().length() > 250){
            characterCount.setTextColor(Color.RED);
        } else {
            characterCount.setTextColor(Color.rgb(0,160,0));
        }

        /// load up any attachments
        if(note.getPath() != null && !note.getPath().equals("")){
            if(note.getFiletype().equals("png")){
                /// load up the image
                Log.i("IMAGE PATH", note.getPath());
                Bitmap bitmap = BitmapFactory.decodeFile(note.getPath());
                this.viewNoteImage.setImageBitmap(bitmap);
            } else if(note.getFiletype().equals("mp3")){
                //load up audio file
                Log.i("AUDIO PATH", note.getPath());
                this.viewNoteImage.setImageResource(R.drawable.playicon);
                viewNoteImage.setOnClickListener(playListener); //play
            }
        }

    }

    /*!
     *  gets called whenever a user leaves the view (to another app/view)
     */
    @Override
    public void onResume(){
        super.onResume();

        /// set up text
        textContent.setText(note.getText());

        /// set up character count
        characterCount.setText(String.valueOf(note.getText().length()));
        if(note.getText().length() > 250){
            characterCount.setTextColor(Color.RED);
        } else {
            characterCount.setTextColor(Color.rgb(0,160,0));
        }

        /// load up any attachments
        if(note.getPath() != null && !note.getPath().equals("")){
            if(note.getFiletype().equals("png")){
                /// load up the image
                Log.i("IMAGE PATH", note.getPath());
                Bitmap bitmap = BitmapFactory.decodeFile(note.getPath());
                this.viewNoteImage.setImageBitmap(bitmap);
                viewNoteImage.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;
            } else if(note.getFiletype().equals("mp3")){
                //load up audio file
                Log.i("AUDIO PATH", note.getPath());
                this.viewNoteImage.setImageResource(R.drawable.playicon);
                viewNoteImage.setOnClickListener(playListener); //play
                viewNoteImage.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;
            }
        } else {
            viewNoteImage.setVisibility(View.INVISIBLE);
            viewNoteImage.getLayoutParams().height = 0;
        }
    }

}
