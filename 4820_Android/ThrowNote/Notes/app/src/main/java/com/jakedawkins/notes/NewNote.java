package com.jakedawkins.notes;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.text.TextWatcher;
import android.text.Editable;
import android.widget.Toast;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class NewNote extends AppCompatActivity {

    private EditText enterTextContent;
    private TextView charCount;
    private LinearLayout linear;
    private Button addPhotoButton;
    private Bitmap bitmap;
    private ImageView newImage;

    private static final int CAMERA_REQUEST = 1888;

    /// to count the number of characters and display to the top right
    private final TextWatcher textCounter = new TextWatcher() {
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        }

        public void onTextChanged(CharSequence s, int start, int before, int count) {
            /// This sets a TextView to the current length
            charCount.setText(String.valueOf(s.length()));

            if (s.length() > 250) {
                charCount.setTextColor(Color.RED);
            } else {
                charCount.setTextColor(Color.rgb(0, 160, 0));
            }
        }

        public void afterTextChanged(Editable s) {
        }
    };

    /*!
     * takes a new note and saves it to the list and DB
     *
     * \param View | button pressed
     */
    public void saveNote(View view) {
        if (enterTextContent.getText().toString().length() == 0) {
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
            return;
        }

        Note note = new Note();

        note.setText(enterTextContent.getText().toString());
        note.createNow();

        /// add the image bitmap to the note for saving
        if (this.bitmap != null) {
            note.setBitmap(this.bitmap);
        }

        AllNotes.getInstance().addNewNote(note);
        RemoteDB.getInstance().syncUpAdd(note);
        finish(); /// return back to the previous activity
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_note);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        /// Get a support ActionBar corresponding to this toolbar
        ActionBar ab = getSupportActionBar();

        /// Enable the Up button
        if (ab != null) {
            ab.setDisplayHomeAsUpEnabled(true);
        }

        enterTextContent = (EditText) findViewById(R.id.enterTextContent);
        enterTextContent.addTextChangedListener(textCounter);
        charCount = (TextView) findViewById(R.id.characterCount);
        this.addPhotoButton = (Button) findViewById(R.id.newPhotoButton);
        this.newImage = (ImageView) findViewById(R.id.newImage);

        ///hide the image/button layout
        this.linear = (LinearLayout) findViewById(R.id.linearImageAndButtonView);
        this.linear.setVisibility(View.INVISIBLE);
        this.linear.getLayoutParams().height = 0;
    }

    //---------------- PHOTO METHODS ----------------

    /// user presses add photo button
    public void newPhoto(View view) {
        Intent i = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(i, 1);
    }

    /// modified new photo
    public void newPhoto2(View view){
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
            startActivityForResult(takePictureIntent, CAMERA_REQUEST);
        }
    }


    /// removes the photo from the note
    public void removePhoto(View view) {
        //hide the image/button layout
        this.linear.setVisibility(View.INVISIBLE);
        this.linear.getLayoutParams().height = 0;

        //show the add photo button
        this.addPhotoButton.setVisibility(View.VISIBLE);
        this.addPhotoButton.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;

        this.bitmap = null;

        //TODO -- this works, but flashes black
        //force redraw
        recreate();
    }

    /// after the image picker returns
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == 1 && resultCode == RESULT_OK && data != null) { //pick image
            //location of selected image
            Uri selectedImage = data.getData();

            try {
                //make a bitmap from the URI
                this.bitmap = MediaStore.Images.Media.getBitmap(this.getContentResolver(), selectedImage);

                this.newImage.setImageBitmap(this.bitmap);

                //make the linear layout visible and expand
                this.linear.setVisibility(View.VISIBLE);
                this.linear.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;

                //hide the add photo button
                this.addPhotoButton.setVisibility(View.INVISIBLE);
                this.addPhotoButton.getLayoutParams().height = 0;
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else if (requestCode == CAMERA_REQUEST && resultCode == RESULT_OK && data != null){ //capture photo
            /// TODO -- full res photo
            Log.i("REQUEST_CODE",Integer.toString(CAMERA_REQUEST));
            Bundle extras = data.getExtras();

            this.bitmap = (Bitmap) extras.get("data");

            this.newImage.setImageBitmap(this.bitmap);

            //make the linear layout visible and expand
            this.linear.setVisibility(View.VISIBLE);
            this.linear.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;

            //hide the add photo button
            this.addPhotoButton.setVisibility(View.INVISIBLE);
            this.addPhotoButton.getLayoutParams().height = 0;
        } else {
            Log.i("REQUEST_CODE",Integer.toString(requestCode));
        }
    }
}