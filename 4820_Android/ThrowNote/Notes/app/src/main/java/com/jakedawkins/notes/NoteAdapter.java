package com.jakedawkins.notes;

import android.content.Context;
import android.media.Image;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * Created by Jake on 2/1/16.
 */
public class NoteAdapter extends ArrayAdapter<Note> {

    ArrayList<Note> notes;

    public NoteAdapter(Context context, ArrayList<Note> notes){
        super(context, 0, notes);
        this.notes = notes;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        /// get data for view
        //TODO -- prevent deleted notes from crashing this
        Note note = notes.get(position);

        /// Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null) {
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.item_note, parent, false);
        }

        /// Lookup view for data population
        TextView noteText = (TextView) convertView.findViewById(R.id.noteText);
        TextView noteTimeStamp = (TextView) convertView.findViewById(R.id.noteTimeStamp);
            //noteTags.setVisibility(View.INVISIBLE);
        ImageView imageIcon = (ImageView) convertView.findViewById(R.id.imageIcon);

        /// Populate the data into the template view using the data object
        noteText.setText(note.getText());

        /// show the time created or updated
        if(note.getUpdated() != null && !note.getUpdated().equals("null")){
            noteTimeStamp.setText(dateParse(note.getUpdated()));
        } else {
            noteTimeStamp.setText(dateParse(note.getCreated()));
        }

        /// hide the image icon if no image with note
        if(note.getPath() == null){
            imageIcon.setVisibility(View.GONE);
        } else if(note.getFiletype().equals("png")){
            imageIcon.setImageResource(R.drawable.imageicon);
        } else if(note.getFiletype().equals("mp3")){
            imageIcon.setImageResource(R.drawable.soundicon);
        }

        /// Return the completed view to render on screen
        return convertView;
    }

    public static String dateParse(String dateTime){
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        try {
            Date date = simpleDateFormat.parse(dateTime);
            return String.format("%tb %<te, %<tY", date);

        } catch (ParseException ex) {
            System.out.println("Exception "+ex);
            return "";
        }
    }

}
