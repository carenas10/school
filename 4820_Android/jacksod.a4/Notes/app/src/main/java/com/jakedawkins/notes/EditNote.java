package com.jakedawkins.notes;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class EditNote extends AppCompatActivity {

    private EditText enterTextContent;
    private EditText enterTags;
    private TextView charCount;
    private int index;
    private ImageView noteImage;

    ///to count the number of characters and display to the top right
    private final TextWatcher textCounter = new TextWatcher() {
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        }

        public void onTextChanged(CharSequence s, int start, int before, int count) {
            //This sets a TextView to the current length
            charCount.setText(String.valueOf(s.length()));


            if(s.length() > 250){
                charCount.setTextColor(Color.RED);
            } else {
                charCount.setTextColor(Color.rgb(0,160,0));
            }
        }

        public void afterTextChanged(Editable s) {
        }
    };

    /*!
     *  takes an already existing note and saves it.
     *
     *  \param View | button clicked
     */
    public void saveNote(View view){
        if(enterTextContent.getText().toString().length() == 0){
            new AlertDialog.Builder(this)
                    .setTitle("No Note Added")
                    .setMessage("You must enter text for the note")
                    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            // continue with delete
                        }
                    })
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .show();
            /*
            .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    // do nothing
                }
            })*/
            return;
        }

        Note note = AllNotes.getInstance().getNotes().get(index);
        String[] tags = enterTags.getText().toString().split(" ");

        note.setText(enterTextContent.getText().toString());

        ///set tags
        note.getTags().clear();
        for(int i=0; i<tags.length; i++){
            if(this.checkTag(tags[i])){
                note.addTag(tags[i]);
            }
        }

        ///let user know not all tags were valid
        if(enterTags.getText().toString().length() > 0 && note.getTags().size() < tags.length){
            Toast toast = Toast.makeText(getApplicationContext(), "Some tags were invalid and not added", Toast.LENGTH_SHORT);
            toast.show();
        }

        AllNotes.getInstance().getNotes().set(index,note);
        AllNotes.getInstance().updateNote(index);
        RemoteDB.getInstance().syncUp();
        finish(); //return back to the previous activity
    }

    /*!
     *  takes an already existing note and removes it from List and DB
     *
     *  \param View | button pressed
     */
    public void deleteNote(View view){
        new AlertDialog.Builder(this)
                .setTitle("Delete Note")
                .setMessage("Are you sure you want to delete this note")
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        AllNotes.getInstance().deleteNote(index);
                        RemoteDB.getInstance().syncUp();
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
        return;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_note);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        /// Get a support ActionBar corresponding to this toolbar
        ActionBar ab = getSupportActionBar();

        /// Enable the Up button
        if (ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }

        enterTextContent = (EditText)findViewById(R.id.enterTextContent);
            enterTextContent.addTextChangedListener(textCounter);
        enterTags = (EditText)findViewById(R.id.enterTags);
        charCount = (TextView)findViewById(R.id.characterCount);

        index = AllNotes.getInstance().getEditIndex();

        ///set up the textfields
        enterTextContent.setText(AllNotes.getInstance().getNotes().get(index).getText());
        enterTags.setText(AllNotes.getInstance().getNotes().get(index).tagsToString());

        ///load up the image
        this.noteImage = (ImageView)findViewById(R.id.noteImage);
        if(AllNotes.getInstance().getNotes().get(index).getPicturePath() != null && !AllNotes.getInstance().getNotes().get(index).getPicturePath().equals("")){
            Log.i("IMAGE PATH", AllNotes.getInstance().getNotes().get(index).getPicturePath());
            Bitmap bitmap = BitmapFactory.decodeFile(AllNotes.getInstance().getNotes().get(index).getPicturePath());
            this.noteImage.setImageBitmap(bitmap);
        }




    }

    //---------------- helper ----------------

    /*!
     *  checks a string to see if it is alphanumeric or _
     *  Also checks for max length of 16 chars
     *
     *  \param tag | String of tag to check for validity
     *
     *  \return boolean | true if valid tag, false otherwise
     */
    private boolean checkTag(String tag){
        if(tag.length() > 16) return false;

        ///check for alphanumeric and underscores
        String regex = "^\\w+$";

        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(tag);

        return matcher.matches();
    }

}
