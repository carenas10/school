package com.jakedawkins.notes;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Bitmap;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Jake on 2/1/16.
 *
 * Singleton class to hold all notes and the database instance for the app
 */
public class AllNotes {
    private ArrayList<Note> notes = new ArrayList<Note>();
    private SQLiteDatabase db = null;
    private int editIndex = 0;
    private static final AllNotes allNotes = new AllNotes();
    private Context context;

    //---------------- GETTERS ----------------

    /*!
     *  Singleton instance of this class
     *  \return allNotes| class variable
     */
    public static AllNotes getInstance(){
        return allNotes;
    }

    public ArrayList<Note> getNotes(){
        return this.notes;
    }

    public SQLiteDatabase getDB(){
        return this.db;
    }

    public int getEditIndex(){
        return this.editIndex;
    }

    public Context getContext() { return this.context; }

    //---------------- SETTERS ----------------

    /*!
     *  Sets up the local SQLite db if needed. No initial checking necessary. Does not harm data.
     *
     *  \param db| already created database to add tables to
     */
    public void setUpDB(SQLiteDatabase db){
        this.db = db;

        this.db.execSQL("CREATE TABLE IF NOT EXISTS notes(id INTEGER PRIMARY KEY, textContent TEXT NOT NULL, created TEXT NOT NULL, updated TEXT, imagePath TEXT, toSync INTEGER DEFAULT 0, toDelete INTEGER DEFAULT 0, remoteID INTEGER DEFAULT 0)");
        this.db.execSQL("CREATE TABLE IF NOT EXISTS tags(id INTEGER PRIMARY KEY, name TEXT NOT NULL)");
        this.db.execSQL("CREATE TABLE IF NOT EXISTS tags_notes(id INTEGER PRIMARY KEY, tag_id INTEGER NOT NULL, note_id INTEGER NOT NULL, FOREIGN KEY (tag_id) REFERENCES tags(id), FOREIGN KEY (note_id) REFERENCES notes(id))");
    }

    public void setEditIndex(int editIndex){
        this.editIndex = editIndex;
    }

    public void setContext(Context context){
        this.context = context;
    }

    //---------------- HELPERS ----------------

    /*!
     *   adds note to the local singleton list as well as the SQLite DB
     *
     *   \param newNote| already initialized note. Needs to have text, created, tags
     */
    public void addNewNote(Note newNote){

        ///add to db if initialized
        if(this.db != null){
            //check if this is a new note or a note being synced
            if(newNote.getRemoteID() == 0){ //new note
                this.db.execSQL("INSERT INTO notes(textContent, created, toSync) VALUES('" + newNote.getText().replaceAll("'","''") + "','" + newNote.getCreated() + "', 1)");
            } else { //sync down note
                this.db.execSQL("INSERT INTO notes(textContent, created, updated, remoteID) VALUES('" + newNote.getText().replaceAll("'","''") + "','" + newNote.getCreated() + "','" + newNote.getUpdated() + "','" + newNote.getRemoteID() + "')");
            }

            ///get id of new note
            Cursor c = this.db.rawQuery("SELECT id FROM notes WHERE textContent='" + newNote.getText().replaceAll("'","''") + "' AND created='" + newNote.getCreated() + "'", null);
            if (c.getCount() > 0){
                int idIndex = c.getColumnIndex("id");
                c.moveToFirst();
                newNote.setID(Integer.parseInt(c.getString(idIndex)));
            }
            c.close();

            //temp set tags from text content
            //TODO -- move this
            newNote.setTags(findHashTags(newNote.getText()));

            ///add tags
            for (int i = 0; i < newNote.getTags().size(); i++) {
                String tag = newNote.getTags().get(i);

                ///if no results, add new tag to db
                c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                if (c.getCount() == 0){
                    this.db.execSQL("INSERT INTO tags(name) VALUES('" + tag + "')");
                    c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                }

                ///get id of tag and add association to newNote
                if (c.getCount() > 0 && newNote.getID() != -1){
                    c.moveToFirst();
                    int idIndex = c.getColumnIndex("id");
                    int tagID = c.getInt(idIndex);

                    this.db.execSQL("INSERT INTO tags_notes(tag_id, note_id) VALUES(" + Integer.toString(tagID) + "," + newNote.getID() + ")");
                }
            }//end for

            if(newNote.getBitmap() != null){
                //add image to internal storage
                File internalStorage = context.getDir("ReportPictures", Context.MODE_PRIVATE);
                File reportFilePath = new File(internalStorage, newNote.getID() + ".png");
                newNote.setPicturePath(reportFilePath.toString());

                //compress and output
                FileOutputStream fos = null;
                try {
                    fos = new FileOutputStream(reportFilePath);
                    newNote.getBitmap().compress(Bitmap.CompressFormat.PNG, 100 /*quality*/, fos);
                    fos.close();
                }
                catch (Exception ex) {
                    Log.i("DATABASE", "Problem updating picture", ex);
                    newNote.setPicturePath("");
                }

                ///add image path to DB
                this.db.execSQL("UPDATE notes SET imagePath='" + newNote.getPicturePath() + "' WHERE id='" + newNote.getID() + "'");
            }
        }//end if

        AllNotes.getInstance().getNotes().add(0, newNote);
    }

    /*!
     *  updates note on the SQLite DB.
     *
     *  \param index| index of the note in the local singleton list to update on the DB.
     */
    public void updateNote(int index){
        Note note = AllNotes.getInstance().getNotes().get(index);

        ///only update db if initialized
        if(this.db != null){
            note.updateNow(); //set updated timedate stamp
            note.setToSync(1);

            this.db.execSQL("UPDATE notes SET " +
                    "textContent='" + note.getText().replaceAll("'","''") + "', " +
                    "updated='" + note.getUpdated() + "', " +
                    "toSync=" + note.getToSync() + ", " +
                    "toDelete=" + note.getToDelete() + ", " +
                    "remoteID=" + note.getRemoteID() + " " +
                    "WHERE id=" + note.getID());

            this.db.execSQL("DELETE FROM tags_notes WHERE note_id=" + note.getID());

            //temp set tags from text content
            //TODO -- move this
            note.setTags(findHashTags(note.getText()));

            ///add tags
            for (int i = 0; i < note.getTags().size(); i++) {
                String tag = note.getTags().get(i);

                ///if no results, add new tag to db
                Cursor c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                if (c.getCount() == 0){
                    this.db.execSQL("INSERT INTO tags(name) VALUES('" + tag + "')");
                    c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                }

                ///get id of tag and add association to newNote
                if (c.getCount() > 0 && note.getID() != -1){
                    c.moveToFirst();
                    int idIndex = c.getColumnIndex("id");
                    int tagID = c.getInt(idIndex);

                    this.db.execSQL("INSERT INTO tags_notes(tag_id, note_id) VALUES(" + Integer.toString(tagID) + "," + note.getID() + ")");
                }
                c.close();
            }//end for
        }//end if
    }

    /*!
     *  updates note on the SQLite DB.
     *
     *  \param index| index of the note in the local singleton list to update on the DB.
     */
    public void updateNote(Note note){
        ///only update db if initialized
        if(this.db != null){
            note.updateNow(); //set updated timedate stamp

            this.db.execSQL("UPDATE notes SET " +
                    "textContent='" + note.getText().replaceAll("'","''") + "', " +
                    "updated='" + note.getUpdated() + "', " +
                    "toSync=" + note.getToSync() + ", " +
                    "toDelete=" + note.getToDelete() + ", " +
                    "remoteID=" + note.getRemoteID() + " " +
                    "WHERE id=" + note.getID());

            this.db.execSQL("DELETE FROM tags_notes WHERE note_id=" + note.getID());

            //temp set tags from text content
            //TODO -- move this
            note.setTags(findHashTags(note.getText()));

            ///add tags
            for (int i = 0; i < note.getTags().size(); i++) {
                String tag = note.getTags().get(i);

                ///if no results, add new tag to db
                Cursor c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                if (c.getCount() == 0){
                    this.db.execSQL("INSERT INTO tags(name) VALUES('" + tag + "')");
                    c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                }

                ///get id of tag and add association to newNote
                if (c.getCount() > 0 && note.getID() != -1){
                    c.moveToFirst();
                    int idIndex = c.getColumnIndex("id");
                    int tagID = c.getInt(idIndex);

                    this.db.execSQL("INSERT INTO tags_notes(tag_id, note_id) VALUES(" + Integer.toString(tagID) + "," + note.getID() + ")");
                }
                c.close();
            }//end for
        }//end if
    }

    /*!
     *  removes note with given index from both singleton list and SQLite DB
     *
     *  \param index| index of note to be removed
     */
    public void deleteNote(int index){
        Note note = this.getNotes().remove(index);

        ///delete note from local storage
        if (note.getPicturePath() != null && note.getPicturePath().length() != 0) {
            File noteFilePath = new File(note.getPicturePath());
            noteFilePath.delete();
        }

        //deleting from DB and of image happens once synced
        this.db.execSQL("UPDATE notes SET toDelete = 1, toSync=1 WHERE id=" + Integer.toString(note.getID()));
        this.db.execSQL("DELETE FROM tags_notes WHERE note_id=" + Integer.toString(note.getID()));
    }

    /*!
     *  removes note with given index from both singleton list and SQLite DB
     *
     *  \param index| index of note to be removed
     */
    public void deleteNote(Note note){

        ///delete note from local storage
        if (note.getPicturePath() != null && note.getPicturePath().length() != 0) {
            File noteFilePath = new File(note.getPicturePath());
            noteFilePath.delete();
        }

        //deleting from DB and of image happens once synced
        this.db.execSQL("UPDATE notes SET toDelete = 1, toSync = 1 WHERE id=" + Integer.toString(note.getID()));
        this.db.execSQL("DELETE FROM tags_notes WHERE note_id=" + Integer.toString(note.getID()));
    }

    /*!
     *  delete marked notes in DB
     */
    public void deleteMarkedNotes(){
        Cursor c = this.db.rawQuery("SELECT id FROM notes WHERE toDelete=1",null);
        int idIndex = c.getColumnIndex("id");

        for(c.moveToFirst(); !c.isAfterLast(); c.moveToNext()){
            int id = c.getInt(idIndex);
            this.db.execSQL("DELETE FROM notes WHERE id=" + id);
            this.db.execSQL("DELETE FROM tags_notes WHERE note_id=" + id);
        }
    }

    /*!
     *  delete all notes in local db and singleton list
     */
    public void deleteAllNotes(){
        this.db.execSQL("DELETE FROM notes");
        this.db.execSQL("DELETE FROM tags");
        this.db.execSQL("DELETE FROM tags_notes");
        this.notes.clear();
    }

    /*!
     *   take notes from local SQLite DB and add them to the singleton notes list
     *
     *   \return boolean| true if operation is success. False if null db.
     */
    public boolean loadNotesFromLocalDB(){
        if(this.db == null) return false;
        Cursor c = this.db.rawQuery("SELECT * FROM notes WHERE toDelete=0", null);

        int textContentIndex = c.getColumnIndex("textContent");
        int idIndex = c.getColumnIndex("id");
        int imagePathIndex = c.getColumnIndex("imagePath");
        int createdIndex = c.getColumnIndex("created");
        int updatedIndex = c.getColumnIndex("updated");
        int toSyncIndex = c.getColumnIndex("toSync");
        int toDeleteIndex = c.getColumnIndex("toDelete");
        int remoteIDIndex = c.getColumnIndex("remoteID");

        ///remove all notes from local list
        AllNotes.getInstance().getNotes().clear();
        Note note;

        ///add notes
        for (c.moveToFirst(); !c.isAfterLast(); c.moveToNext()) {
            note = new Note();
            note.setID(Integer.parseInt(c.getString(idIndex)));
            note.setText(c.getString(textContentIndex));
            note.setPicturePath(c.getString(imagePathIndex));
            note.setCreated(c.getString(createdIndex));
            note.setUpdated(c.getString(updatedIndex));
            note.setToSync(c.getInt(toSyncIndex));
            note.setToDelete(c.getInt(toDeleteIndex));
            note.setRemoteID(c.getInt(remoteIDIndex));
            AllNotes.getInstance().getNotes().add(0, note);
        }

        c.close();

        ///add tags to notes
        for(int i=0; i<this.notes.size(); i++){
            note = this.notes.get(i);
            c = this.db.rawQuery("SELECT * FROM tags_notes INNER JOIN tags ON tags_notes.tag_id = tags.id WHERE note_id=" + note.getID(), null);

            int tagIndex = c.getColumnIndex("name");

            for(c.moveToFirst(); !c.isAfterLast(); c.moveToNext()){
                note.addTag(c.getString(tagIndex));
            }

            c.close();
        }

        return true;
    }

    public Note fetchNote(int id){
        if(this.db == null) return null;
        Cursor c = this.db.rawQuery("SELECT * FROM notes WHERE id=" + id, null);

        int textContentIndex = c.getColumnIndex("textContent");
        int idIndex = c.getColumnIndex("id");
        int imagePathIndex = c.getColumnIndex("imagePath");
        int createdIndex = c.getColumnIndex("created");
        int updatedIndex = c.getColumnIndex("updated");
        int toSyncIndex = c.getColumnIndex("toSync");
        int toDeleteIndex = c.getColumnIndex("toDelete");
        int remoteIDIndex = c.getColumnIndex("remoteID");
        Note note = null;

        ///add notes
        if(c.getCount() > 0){
            for (c.moveToFirst(); !c.isAfterLast(); c.moveToNext()) {
                note = new Note();
                note.setID(Integer.parseInt(c.getString(idIndex)));
                note.setText(c.getString(textContentIndex));
                note.setPicturePath(c.getString(imagePathIndex));
                note.setRemoteID(c.getInt(remoteIDIndex));
                note.setCreated(c.getString(createdIndex));
                note.setUpdated(c.getString(updatedIndex));
                note.setToSync(c.getInt(toSyncIndex));
                note.setToDelete(c.getInt(toDeleteIndex));
            }
        }
        c.close();

        ///add tags to notes
        if(note != null){
            c = this.db.rawQuery("SELECT * FROM tags_notes INNER JOIN tags ON tags_notes.tag_id = tags.id WHERE note_id=" + note.getID(), null);

            int tagIndex = c.getColumnIndex("name");

            if(c.getCount() > 0){
                for(c.moveToFirst(); !c.isAfterLast(); c.moveToNext()){
                    note.addTag(c.getString(tagIndex));
                }
            }

            c.close();
        }

        return note;
    }

    //------------------------ HELPERS ------------------------
    public static ArrayList<String> findHashTags(String input){
        Pattern MY_PATTERN = Pattern.compile("#(\\w+)");
        Matcher mat = MY_PATTERN.matcher(input);
        ArrayList<String> tags =new ArrayList<String>();
        while (mat.find()) {
            tags.add(mat.group(1));
        }

        return tags;
    }

}
