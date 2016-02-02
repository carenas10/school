package com.jakedawkins.notes;

import java.lang.reflect.Array;
import java.util.ArrayList;

/**
 * Created by Jake on 2/1/16.
 *
 * Singleton class to hold all notes
 */
public class AllNotes {
    private ArrayList<Note> notes = new ArrayList<Note>();

    public ArrayList<Note> getNotes(){
        return this.notes;
    }

    public void addNote(Note newNote){
        this.notes.add(newNote);
    }

    private static final AllNotes allNotes = new AllNotes();
    public static AllNotes getInstance(){
        return allNotes;
    }

}
