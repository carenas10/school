package com.jakedawkins.notes;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by Jake on 2/1/16.
 */
public class NoteAdapter extends ArrayAdapter<Note> {

    ArrayList<Note> notes = AllNotes.getInstance().getNotes();

    public NoteAdapter(Context context, ArrayList<Note> notes){
        super(context, 0, notes);
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

        ///Populate the data into the template view using the data object
        noteText.setText(note.getText());
        noteTags.setText(note.tagsToHashtags());

        ///Return the completed view to render on screen
        return convertView;
    }

}
