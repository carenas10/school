package com.jakedawkins.notes;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Bundle;
import android.renderscript.Script;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class EditNote extends AppCompatActivity {

    private EditText enterTextContent;
    private TextView charCount;
    private int index;
    private ImageView editImage;
    private LinearLayout linear;

    private Button addPhotoButton;
    private Button addAudioButton;
    private Button removeButton;

    //------------------------ AUDIO METHODS -------------------------


    //------------------------ PHOTO METHODS -------------------------


    //------------------------ UI METHODS -------------------------

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
        charCount = (TextView)findViewById(R.id.characterCount);

        index = AllNotes.getInstance().getEditIndex();

        ///set up the textfields
        enterTextContent.setText(AllNotes.getInstance().getNotes().get(index).getText());

        /// set up buttons
        this.addAudioButton = (Button) findViewById(R.id.newAudioButton);
        this.addPhotoButton = (Button) findViewById(R.id.newPhotoButton);
        this.removeButton = (Button) findViewById(R.id.editRemoveButton);

        /// set up linear image and remove button view
        this.linear = (LinearLayout) findViewById(R.id.linearEditImageAndButtonView);

        /// set up image view
        this.editImage = (ImageView)findViewById(R.id.editImage);

        //note has an image
        if(AllNotes.getInstance().getNotes().get(index).getPath() != null && !AllNotes.getInstance().getNotes().get(index).getPath().equals("")){
            Log.i("IMAGE PATH", AllNotes.getInstance().getNotes().get(index).getPath());
            Bitmap bitmap = BitmapFactory.decodeFile(AllNotes.getInstance().getNotes().get(index).getPath());
            this.editImage.setImageBitmap(bitmap);

            //hide add buttons
            this.addPhotoButton.setVisibility(View.INVISIBLE);
            this.addPhotoButton.getLayoutParams().height = 0;
            this.addAudioButton.setVisibility(View.INVISIBLE);
            this.addAudioButton.getLayoutParams().height = 0;
        } else { //note has no image
            //hide the image and remove button
            this.linear.setVisibility(View.INVISIBLE);
            this.linear.getLayoutParams().height = 0;
        }
    }

    //------------------------ HELPER METHODS -------------------------

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

                        }
                    })
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .show();
            return;
        }

        Note note = AllNotes.getInstance().getNotes().get(index);

        note.setText(enterTextContent.getText().toString());

        AllNotes.getInstance().getNotes().set(index,note);
        AllNotes.getInstance().updateNote(index);
        RemoteDB.getInstance().syncUpUpdate(note);
        finish(); //return back to the previous activity
    }

    /// to count the number of characters and display to the top right
    private final TextWatcher textCounter = new TextWatcher() {
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        }

        public void onTextChanged(CharSequence s, int start, int before, int count) {
            /// This sets a TextView to the current length
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
}
