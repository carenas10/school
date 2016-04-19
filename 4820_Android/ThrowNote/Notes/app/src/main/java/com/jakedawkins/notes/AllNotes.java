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
     *
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
        this.db.execSQL("CREATE TABLE IF NOT EXISTS filetypes(id INTEGER PRIMARY KEY, filetype TEXT NOT NULL)");
        this.db.execSQL("CREATE TABLE IF NOT EXISTS attachments(id INTEGER PRIMARY KEY, filename TEXT NOT NULL, filetype_id INTEGER NOT NULL, note_id INTEGER NOT NULL, path TEXT NOT NULL, FOREIGN KEY (filetype_id) REFERENCES filetypes(id), FOREIGN KEY (note_id) REFERENCES notes(id)) ");
        this.db.execSQL("CREATE TABLE IF NOT EXISTS tags(id INTEGER PRIMARY KEY, name TEXT NOT NULL)");
        this.db.execSQL("CREATE TABLE IF NOT EXISTS tags_notes(id INTEGER PRIMARY KEY, tag_id INTEGER NOT NULL, note_id INTEGER NOT NULL, FOREIGN KEY (tag_id) REFERENCES tags(id), FOREIGN KEY (note_id) REFERENCES notes(id))");

        //allowed filetypes
        if(AllNotes.getFiletypeID("png") == -1){
            this.db.execSQL("INSERT INTO filetypes(id,filetype) VALUES(1,'png')");
        }
        if(AllNotes.getFiletypeID("mp3") == -1) {
            this.db.execSQL("INSERT INTO filetypes(id,filetype) VALUES(2,'mp3')");
        }
    }

    public void setEditIndex(int editIndex){
        this.editIndex = editIndex;
    }

    public void setContext(Context context){ this.context = context; }

    //---------------- HELPERS ----------------

    /*!
     *   adds note to the local singleton list as well as the SQLite DB
     *
     *   \param newNote| already initialized note. Needs to have text, created, tags
     */
    public void addNewNote(Note newNote){

        /// add to db if initialized
        if(this.db != null){
            /// check if this is a new note or a note being synced
            if(newNote.getRemoteID() == 0){ //new note
                this.db.execSQL("INSERT INTO notes(textContent, created, toSync) VALUES('" + newNote.getText().replaceAll("'","''") + "','" + newNote.getCreated() + "', 1)");
            } else { //sync down note
                this.db.execSQL("INSERT INTO notes(textContent, created, updated, remoteID) VALUES('" + newNote.getText().replaceAll("'","''") + "','" + newNote.getCreated() + "','" + newNote.getUpdated() + "','" + newNote.getRemoteID() + "')");
            }

            /// get id of new note
            Cursor c = this.db.rawQuery("SELECT id FROM notes WHERE textContent='" + newNote.getText().replaceAll("'","''") + "' AND created='" + newNote.getCreated() + "'", null);
            if (c.getCount() > 0){
                int idIndex = c.getColumnIndex("id");
                c.moveToFirst();
                newNote.setID(Integer.parseInt(c.getString(idIndex)));
            }
            c.close();

            /// set the tags from text content
            newNote.setTags(findHashTags(newNote.getText()));

            /// add tags
            for (int i = 0; i < newNote.getTags().size(); i++) {
                String tag = newNote.getTags().get(i);

                /// if no results, add new tag to db
                c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                if (c.getCount() == 0){
                    this.db.execSQL("INSERT INTO tags(name) VALUES('" + tag + "')");
                    c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                }

                /// get id of tag and add association to newNote
                if (c.getCount() > 0 && newNote.getID() != -1){
                    c.moveToFirst();
                    int idIndex = c.getColumnIndex("id");
                    int tagID = c.getInt(idIndex);

                    this.db.execSQL("INSERT INTO tags_notes(tag_id, note_id) VALUES(" + Integer.toString(tagID) + "," + newNote.getID() + ")");
                }
            }//end for

            /// note has an image
            if(newNote.getBitmap() != null){
                /// add image to internal storage
                File internalStorage = context.getDir("NotePictures", Context.MODE_PRIVATE);
                File reportFilePath = new File(internalStorage, newNote.getID() + ".png");

                newNote.setPath(reportFilePath.toString());
                newNote.setFilename(newNote.getID() + ".png");
                newNote.setFiletype("png");

                /// compress and output
                FileOutputStream fos;
                try {
                    fos = new FileOutputStream(reportFilePath);
                    newNote.getBitmap().compress(Bitmap.CompressFormat.PNG, 100 /*quality*/, fos);
                    fos.close();
                }
                catch (Exception ex) {
                    Log.i("DATABASE", "Problem updating picture", ex);
                    newNote.setPath("");
                }

                /// add attachment to DB
                this.db.execSQL("INSERT INTO attachments(filename, path, filetype_id, note_id) VALUES('" +
                        newNote.getFilename() + "','" +
                        newNote.getPath() + "','" +
                        getFiletypeID(newNote.getFiletype()) + "','" +
                        newNote.getID() +
                        "')");
            } else if(newNote.getPath() != null){
                /// note has audio

                /// add attachment to DB
                this.db.execSQL("INSERT INTO attachments(filename, path, filetype_id, note_id) VALUES('" +
                        newNote.getFilename() + "','" +
                        newNote.getPath() + "','" +
                        getFiletypeID(newNote.getFiletype()) + "','" +
                        newNote.getID() +
                        "')");
            }
        }//end if db

        AllNotes.getInstance().getNotes().add(0, newNote);
    }

    /*!
     *  updates note on the SQLite DB.
     *
     *  \param index| index of the note in the local singleton list to update on the DB.
     */
    public void updateNote(int index){
        Note note = AllNotes.getInstance().getNotes().get(index);

        /// only update db if initialized
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

            /// set tags from text content
            note.setTags(findHashTags(note.getText()));

            /// add tags
            for (int i = 0; i < note.getTags().size(); i++) {
                String tag = note.getTags().get(i);

                /// if no results, add new tag to db
                Cursor c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                if (c.getCount() == 0){
                    this.db.execSQL("INSERT INTO tags(name) VALUES('" + tag + "')");
                    c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                }

                /// get id of tag and add association to newNote
                if (c.getCount() > 0 && note.getID() != -1){
                    c.moveToFirst();
                    int idIndex = c.getColumnIndex("id");
                    int tagID = c.getInt(idIndex);

                    this.db.execSQL("INSERT INTO tags_notes(tag_id, note_id) VALUES(" + Integer.toString(tagID) + "," + note.getID() + ")");
                }
                c.close();
            }//end for

            /// handle attachments
            /// delete all old attachments
            this.db.execSQL("DELETE FROM attachments WHERE note_id='" + note.getID() + "'");

            //add attachments back
            /// note has an image
            if(note.getBitmap() != null){
                /// add image to internal storage
                File internalStorage = context.getDir("NotePictures", Context.MODE_PRIVATE);
                File reportFilePath = new File(internalStorage, note.getID() + ".png");
                note.setPath(reportFilePath.toString());

                /// compress and output
                FileOutputStream fos;
                try {
                    fos = new FileOutputStream(reportFilePath);
                    note.getBitmap().compress(Bitmap.CompressFormat.PNG, 100 /*quality*/, fos);
                    fos.close();
                }
                catch (Exception ex) {
                    Log.i("DATABASE", "Problem updating picture", ex);
                    note.setPath("");
                }

                /// add attachment to DB
                this.db.execSQL("INSERT INTO attachments(filename, path, filetype_id, note_id) VALUES('" +
                        note.getFilename() + "','" +
                        note.getPath() + "','" +
                        getFiletypeID(note.getFiletype()) + "','" +
                        note.getID() +
                        "')");
            } else if(note.getPath() != null){
                /// note has audio

                /// add attachment to DB
                this.db.execSQL("INSERT INTO attachments(filename, path, filetype_id, note_id) VALUES('" +
                        note.getFilename() + "','" +
                        note.getPath() + "','" +
                        getFiletypeID(note.getFiletype()) + "','" +
                        note.getID() +
                        "')");
            }
        }//end if
    }

    /*!
     *  updates note on the SQLite DB.
     *
     *  \param index| index of the note in the local singleton list to update on the DB.
     */
    public void updateNote(Note note){
        /// only update db if initialized
        if(this.db != null){
            note.updateNow(); //set updated timedate stamp

            this.db.execSQL("UPDATE notes SET " +
                    "textContent='" + note.getText().replaceAll("'", "''") + "', " +
                    "updated='" + note.getUpdated() + "', " +
                    "toSync=" + note.getToSync() + ", " +
                    "toDelete=" + note.getToDelete() + ", " +
                    "remoteID=" + note.getRemoteID() + " " +
                    "WHERE id=" + note.getID());

            this.db.execSQL("DELETE FROM tags_notes WHERE note_id=" + note.getID());

            /// set tags from text content
            note.setTags(findHashTags(note.getText()));

            /// add tags
            for (int i = 0; i < note.getTags().size(); i++) {
                String tag = note.getTags().get(i);

                /// if no results, add new tag to db
                Cursor c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                if (c.getCount() == 0){
                    this.db.execSQL("INSERT INTO tags(name) VALUES('" + tag + "')");
                    c = this.db.rawQuery("SELECT * FROM tags WHERE name='" + tag + "'", null);
                }

                /// get id of tag and add association to newNote
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

        /// delete note from local storage
        if (note.getPath() != null && note.getPath().length() != 0) {
            File noteFilePath = new File(note.getPath());
            boolean success = noteFilePath.delete();
            Log.i("DELETE_FILE",Boolean.toString(success));
        }

        /// deleting from DB and of image happens once synced
        this.db.execSQL("UPDATE notes SET toDelete = 1, toSync=1 WHERE id=" + Integer.toString(note.getID()));
        this.db.execSQL("DELETE FROM tags_notes WHERE note_id=" + Integer.toString(note.getID()));
        this.db.execSQL("DELETE FROM attachments WHERE note_id=" + note.getID());
    }

    /*!
     *  removes note with given index from both singleton list and SQLite DB
     *
     *  \param index| index of note to be removed
     */
    public void deleteNote(Note note){

        /// delete note from local storage
        if (note.getPath() != null && note.getPath().length() != 0) {
            File noteFilePath = new File(note.getPath());
            boolean success = noteFilePath.delete();
            Log.i("DELETE_FILE", Boolean.toString(success));
        }

        for(int i=0; i<getNotes().size(); i++){
            if(getNotes().get(i).getID() == note.getID()){
                getNotes().remove(i);
            }
        }

        /// deleting from DB and of image happens once synced
        this.db.execSQL("UPDATE notes SET toDelete = 1, toSync = 1 WHERE id=" + Integer.toString(note.getID()));
        this.db.execSQL("DELETE FROM tags_notes WHERE note_id=" + Integer.toString(note.getID()));
        this.db.execSQL("DELETE FROM attachments WHERE note_id=" + note.getID());
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
            this.db.execSQL("DELETE FROM attachments WHERE note_id=" + id);
        }

        c.close();
    }

    /*!
     *  delete all notes in local db and singleton list
     */
    // TODO -- remove files in save dir
    public void deleteAllNotes(){
        this.db.execSQL("DELETE FROM notes");
        this.db.execSQL("DELETE FROM tags");
        this.db.execSQL("DELETE FROM tags_notes");
        this.db.execSQL("DELETE FROM attachments");
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
        int createdIndex = c.getColumnIndex("created");
        int updatedIndex = c.getColumnIndex("updated");
        int toSyncIndex = c.getColumnIndex("toSync");
        int toDeleteIndex = c.getColumnIndex("toDelete");
        int remoteIDIndex = c.getColumnIndex("remoteID");

        /// remove all notes from local list
        AllNotes.getInstance().getNotes().clear();
        Note note;

        /// add notes
        for (c.moveToFirst(); !c.isAfterLast(); c.moveToNext()) {
            note = new Note();
            note.setID(Integer.parseInt(c.getString(idIndex)));
            note.setText(c.getString(textContentIndex));
            note.setCreated(c.getString(createdIndex));
            note.setUpdated(c.getString(updatedIndex));
            note.setToSync(c.getInt(toSyncIndex));
            note.setToDelete(c.getInt(toDeleteIndex));
            note.setRemoteID(c.getInt(remoteIDIndex));
            AllNotes.getInstance().getNotes().add(0, note);
        }

        c.close();

        /// add tags to notes
        for(int i=0; i<this.notes.size(); i++){
            note = this.notes.get(i);
            c = this.db.rawQuery("SELECT * FROM tags_notes INNER JOIN tags ON tags_notes.tag_id = tags.id WHERE note_id=" + note.getID(), null);

            int tagIndex = c.getColumnIndex("name");

            for(c.moveToFirst(); !c.isAfterLast(); c.moveToNext()){
                note.addTag(c.getString(tagIndex));
            }

            c.close();
        }

        /// add attachments to notes
        for(int i=0; i<this.notes.size(); i++){
            note = this.notes.get(i);
            c = this.db.rawQuery("SELECT * FROM attachments WHERE note_id=" + note.getID(), null);

            int filenameIndex = c.getColumnIndex("filename");
            int filetypeIDIndex = c.getColumnIndex("filetype_id");
            int pathIndex = c.getColumnIndex("path");

            for(c.moveToFirst(); !c.isAfterLast(); c.moveToNext()){
                note.setFilename(c.getString(filenameIndex));
                note.setFiletype(getFiletypeName(c.getInt(filetypeIDIndex)));
                note.setPath(c.getString(pathIndex));
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
        int createdIndex = c.getColumnIndex("created");
        int updatedIndex = c.getColumnIndex("updated");
        int toSyncIndex = c.getColumnIndex("toSync");
        int toDeleteIndex = c.getColumnIndex("toDelete");
        int remoteIDIndex = c.getColumnIndex("remoteID");
        Note note = null;

        /// add notes
        if(c.getCount() > 0){
            for (c.moveToFirst(); !c.isAfterLast(); c.moveToNext()) {
                note = new Note();
                note.setID(Integer.parseInt(c.getString(idIndex)));
                note.setText(c.getString(textContentIndex));
                note.setRemoteID(c.getInt(remoteIDIndex));
                note.setCreated(c.getString(createdIndex));
                note.setUpdated(c.getString(updatedIndex));
                note.setToSync(c.getInt(toSyncIndex));
                note.setToDelete(c.getInt(toDeleteIndex));
            }
        }
        c.close();

        /// add tags to notes
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

        /// add attachments to note
        if(note != null){
            c = this.db.rawQuery("SELECT * FROM attachments WHERE note_id=" + note.getID(), null);

            int filenameIndex = c.getColumnIndex("filename");
            int filetypeIDIndex = c.getColumnIndex("filetype_id");
            int pathIndex = c.getColumnIndex("path");

            for(c.moveToFirst(); !c.isAfterLast(); c.moveToNext()){
                note.setFilename(c.getString(filenameIndex));
                note.setFiletype(getFiletypeName(c.getInt(filetypeIDIndex)));
                note.setPath(c.getString(pathIndex));
            }

            c.close();
        }

        return note;
    }

    //------------------------ HELPERS ------------------------
    /// finds the hashtags in text and returns an arraylist of the tags without the #
    public static ArrayList<String> findHashTags(String input){
        Pattern MY_PATTERN = Pattern.compile("#(\\w+)");
        Matcher mat = MY_PATTERN.matcher(input);
        ArrayList<String> tags =new ArrayList<String>();
        while (mat.find()) {
            tags.add(mat.group(1));
        }

        return tags;
    }

    /*!
    *   get id of a filetype from local db
    */
    public static int getFiletypeID(String filetype){
        Cursor c = AllNotes.getInstance().db.rawQuery("SELECT * FROM filetypes WHERE filetype='" + filetype + "'", null);

        int idIndex = c.getColumnIndex("id");

        if(c.getCount() > 0) c.moveToFirst();
        else return -1;

        int filetypeID = c.getInt(idIndex);

        c.close();
        return filetypeID;
    }

    /*!
    *   get name of a filetype, given the ID
    */
    public static String getFiletypeName(int filetypeID){
        Cursor c = AllNotes.getInstance().db.rawQuery("SELECT * FROM filetypes WHERE id=" + filetypeID, null);

        int filetypeIndex = c.getColumnIndex("filetype");

        if(c.getCount() > 0) c.moveToFirst();
        else return "";

        String filetype = c.getString(filetypeIndex);

        c.close();
        return filetype;
    }

}
