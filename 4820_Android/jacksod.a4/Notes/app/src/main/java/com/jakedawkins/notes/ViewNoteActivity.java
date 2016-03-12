package com.jakedawkins.notes;

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

        //set up text
        textContent.setText(note.getText());

        //set up character count
        characterCount.setText(String.valueOf(note.getText().length()));
        if(note.getText().length() > 250){
            characterCount.setTextColor(Color.RED);
        } else {
            characterCount.setTextColor(Color.rgb(0,160,0));
        }

        ///load up the image
        if(note.getPicturePath() != null && !note.getPicturePath().equals("")){
            Log.i("IMAGE PATH", note.getPicturePath());
            Bitmap bitmap = BitmapFactory.decodeFile(note.getPicturePath());
            this.viewNoteImage.setImageBitmap(bitmap);
        }

    }

}
