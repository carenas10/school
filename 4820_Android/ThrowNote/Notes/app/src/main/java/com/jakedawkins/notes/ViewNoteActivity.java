package com.jakedawkins.notes;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

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

        /// load up the image
        if(note.getPicturePath() != null && !note.getPicturePath().equals("")){
            Log.i("IMAGE PATH", note.getPicturePath());
            Bitmap bitmap = BitmapFactory.decodeFile(note.getPicturePath());
            this.viewNoteImage.setImageBitmap(bitmap);
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
    }

}
