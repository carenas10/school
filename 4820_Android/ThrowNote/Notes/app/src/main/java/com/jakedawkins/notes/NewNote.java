package com.jakedawkins.notes;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
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

import java.io.File;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class NewNote extends AppCompatActivity {

    private EditText enterTextContent;
    private TextView charCount;
    private LinearLayout linear;
    private Button addPhotoButton;
    private Button addAudioButton;
    private Bitmap bitmap;
    private Button removeButton;
    private ImageView newImage;

    //audio
    private String filename = null;
    private String outputFile = null;
    MediaRecorder recorder;
    MediaPlayer mPlayer;

    private static final int CAMERA_REQUEST = 1888;

    //---------------- AUDIO METHODS ----------------

    // PRE-RECORDING
    //user taps add photo button
    public void addAudio(View view){
        //check for permissions
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED){
            if (enterTextContent.getText().toString().length() == 0) {
                new AlertDialog.Builder(this)
                        .setTitle("Not Allowed")
                        .setMessage("You must approve this permission in settings")
                        .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {
                                // continue with delete
                            }
                        })
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .show();
            }
        } else { //permissions granted
            /// hide the add photo/audio button
            this.addPhotoButton.setVisibility(View.INVISIBLE);
            this.addPhotoButton.getLayoutParams().height = 0;
            this.addAudioButton.setVisibility(View.INVISIBLE);
            this.addAudioButton.getLayoutParams().height = 0;

            /// make the linear layout visible and expand
            this.linear.setVisibility(View.VISIBLE);
            this.linear.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;
            this.newImage.setImageResource(R.drawable.recordicon);

            /// add method to image for recording
            newImage.setOnClickListener(recordAudioListener);
            removeButton.setOnClickListener(removeAudio);
        }
    }

    //RECORD
    View.OnClickListener recordAudioListener = new View.OnClickListener() {
        public void onClick(View v) {
            //set filename
            outputFile = Environment.getExternalStorageDirectory().getAbsolutePath();
            //outputFile = outputFile + "/" + now() + ".3gp";
            outputFile = outputFile + "/" + now() + ".mp3";

            recorder = new MediaRecorder();
            recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
            //recorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
            recorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            recorder.setOutputFile(outputFile);
            //recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
            recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);


            try {
                recorder.prepare();
            } catch (IOException e) {
                e.printStackTrace();
            }

            recorder.start();
            Log.i("RECORD", "CLICKED");
            newImage.setImageResource(R.drawable.stopicon);
            newImage.setOnClickListener(stopRecordListener);
            Toast.makeText(getApplicationContext(), "Recording started", Toast.LENGTH_SHORT).show();
        }
    };

    //DONE RECORDING
    View.OnClickListener stopRecordListener = new View.OnClickListener() {
        public void onClick(View v) {
            Log.i("STOP","CLICKED");
            newImage.setImageResource(R.drawable.playicon);
            newImage.setOnClickListener(playListener); //play

            //stop recording
            recorder.stop();
            recorder.release();
            recorder  = null;

            Toast.makeText(getApplicationContext(), "Audio recorded successfully",Toast.LENGTH_SHORT).show();
        }
    };

    //REMOVE AUDIO CLIPS
    View.OnClickListener removeAudio = new View.OnClickListener() {
        public void onClick(View v) {
            Log.i("REMOVE","CLICKED");

            /// hide the image/button layout
            linear.setVisibility(View.INVISIBLE);
            linear.getLayoutParams().height = 0;

            /// show the add photo button
            addPhotoButton.setVisibility(View.VISIBLE);
            addPhotoButton.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;
            addAudioButton.setVisibility(View.VISIBLE);
            addAudioButton.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;

            /// remove audio
            outputFile = null;
            filename = null;
            recorder = null;

            //force redraw
            recreate();

            Toast.makeText(getApplicationContext(), "Audio removed",Toast.LENGTH_SHORT).show();
        }
    };

    //PLAY AUDIO
    View.OnClickListener playListener = new View.OnClickListener() {
        public void onClick(View v) {
            Log.i("PLAY", "CLICKED");
            if(mPlayer != null && mPlayer.isPlaying()){
                mPlayer.stop();
            }
            mPlayer = new MediaPlayer();

            try {
                mPlayer.setDataSource(outputFile);
                mPlayer.prepare();
                mPlayer.start();
            }
            catch (IOException e) {
                e.printStackTrace();
            }

            Toast.makeText(getApplicationContext(), "Playing audio", Toast.LENGTH_SHORT).show();
        }
    };

    //---------------- PHOTO METHODS ----------------

    /// user presses add photo button
    public void newPhoto(View view) {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
            startActivityForResult(takePictureIntent, CAMERA_REQUEST);
        }
        removeButton.setOnClickListener(removePhoto);
    }

    View.OnClickListener removePhoto = new View.OnClickListener() {
        public void onClick(View v) {
            /// hide the image/button layout
            linear.setVisibility(View.INVISIBLE);
            linear.getLayoutParams().height = 0;

            /// show the add buttons
            addPhotoButton.setVisibility(View.VISIBLE);
            addPhotoButton.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;
            addAudioButton.setVisibility(View.VISIBLE);
            addAudioButton.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;

            /// remove photo
            bitmap = null;

            //force redraw
            recreate();
        }
    };



    //---------------- UI METHODS ----------------

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_note);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        /// Get a support ActionBar corresponding to this toolbar
        ActionBar ab = getSupportActionBar();

        /// Enable the Up button
        if (ab != null) { ab.setDisplayHomeAsUpEnabled(true); }

        /// set up text field
        enterTextContent = (EditText) findViewById(R.id.enterTextContent);
        enterTextContent.addTextChangedListener(textCounter);
        charCount = (TextView) findViewById(R.id.characterCount);

        /// set up buttons
        this.addPhotoButton = (Button) findViewById(R.id.newPhotoButton);
        this.addAudioButton = (Button) findViewById(R.id.newAudioButton);
        this.removeButton = (Button) findViewById(R.id.button);

        /// set up image
        this.newImage = (ImageView) findViewById(R.id.newImage);

        /// hide the image/button layout
        this.linear = (LinearLayout) findViewById(R.id.linearImageAndButtonView);
        this.linear.setVisibility(View.INVISIBLE);
        this.linear.getLayoutParams().height = 0;
    }

    /// after the image picker returns
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == CAMERA_REQUEST && resultCode == RESULT_OK && data != null){ //capture photo
            Log.i("REQUEST_CODE", Integer.toString(CAMERA_REQUEST));
            Bundle extras = data.getExtras();

            this.bitmap = (Bitmap) extras.get("data");

            this.newImage.setImageBitmap(this.bitmap);

            //make the linear layout visible and expand
            this.linear.setVisibility(View.VISIBLE);
            this.linear.getLayoutParams().height = LinearLayout.LayoutParams.WRAP_CONTENT;

            //hide the add photo/audio button
            this.addPhotoButton.setVisibility(View.INVISIBLE);
            this.addPhotoButton.getLayoutParams().height = 0;
            this.addAudioButton.setVisibility(View.INVISIBLE);
            this.addAudioButton.getLayoutParams().height = 0;

        } else {
            Log.i("REQUEST_CODE",Integer.toString(requestCode));
        }
    }

    //---------------- HELPER METHODS ----------------

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
        if (this.bitmap != null) { note.setBitmap(this.bitmap); }
        else if (this.outputFile != null) {
            note.setFiletype("mp3");
            note.setFilename(filename);
            note.setPath(outputFile);
        }

        AllNotes.getInstance().addNewNote(note);
        RemoteDB.getInstance().syncUpAdd(note);
        finish(); /// return back to the previous activity
    }

    /// to count the number of characters and display to the top right
    private final TextWatcher textCounter = new TextWatcher() {
        public void beforeTextChanged(CharSequence s, int start, int count, int after) { }

        public void onTextChanged(CharSequence s, int start, int before, int count) {
            /// This sets a TextView to the current length
            charCount.setText(String.valueOf(s.length()));

            if (s.length() > 250) {
                charCount.setTextColor(Color.RED);
            } else {
                charCount.setTextColor(Color.rgb(0, 160, 0));
            }
        }

        public void afterTextChanged(Editable s) { }
    };

    /*!
     *  Used to generate a mySQL-like timedate string of right now
     *  in format of YYYY-MM-DD HH:MM:SS
     *
     *  \return String| current timeDate string
     */
    public String now(){
        DateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
        Date date = new Date();
        return dateFormat.format(date); //2014-08-06 15:59:48
    }
}