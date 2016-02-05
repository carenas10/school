package com.jakedawkins.notes;

import android.graphics.Color;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.text.TextWatcher;
import android.text.Editable;
import android.widget.Toast;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class NewNote extends AppCompatActivity {

    private EditText enterTextContent;
    private EditText enterTags;
    private TextView charCount;

    //to count the number of characters and display to the top right
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

    public void saveNote(View view){

        Note note = new Note();
        String[] tags = enterTags.getText().toString().split(" ");

        note.setText(enterTextContent.getText().toString());

        //set tags
        for(int i=0; i<tags.length; i++){
            if(this.checkTag(tags[i])){
                note.addTag(tags[i]);
            }
        }

        //let user know not all tags were valid
        if(enterTags.getText().toString().length() > 0 && note.getTags().size() < tags.length){
            Toast toast = Toast.makeText(getApplicationContext(), "Some tags were invalid and not added", Toast.LENGTH_SHORT);
            toast.show();
        }

        AllNotes.getInstance().addNote(note);
        finish(); //return back to the previous activity
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_note);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        // Get a support ActionBar corresponding to this toolbar
        ActionBar ab = getSupportActionBar();

        // Enable the Up button
        if (ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }

        enterTextContent = (EditText)findViewById(R.id.enterTextContent);
            enterTextContent.addTextChangedListener(textCounter);
        enterTags = (EditText)findViewById(R.id.enterTags);
        charCount = (TextView)findViewById(R.id.characterCount);
    }

    //---------------- helper ----------------
    private boolean checkTag(String tag){
        if(tag.length() > 16) return false;

        //check for alphanumeric and underscores
        String regex = "^\\w+$";

        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(tag);

        return matcher.matches();
    }

}
