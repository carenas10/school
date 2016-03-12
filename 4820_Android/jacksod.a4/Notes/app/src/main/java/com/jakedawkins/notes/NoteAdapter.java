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

import java.util.ArrayList;

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
        ///get data for view
        Note note = notes.get(position);

        ///Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null) {
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.item_note, parent, false);
        }

        ///Lookup view for data population
        TextView noteText = (TextView) convertView.findViewById(R.id.noteText);
        TextView noteTags = (TextView) convertView.findViewById(R.id.noteTags);
            noteTags.setVisibility(View.INVISIBLE);
        ImageView imageIcon = (ImageView) convertView.findViewById(R.id.imageIcon);

        ///Populate the data into the template view using the data object
        noteText.setText(note.getText());

        ///hide the image icon if no image with note
        if(note.getPicturePath() == null){
            imageIcon.setVisibility(View.GONE);
        }

        ///Return the completed view to render on screen
        return convertView;
    }

}
