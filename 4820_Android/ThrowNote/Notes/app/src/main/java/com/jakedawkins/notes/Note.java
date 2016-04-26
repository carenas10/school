package com.jakedawkins.notes;

import android.graphics.Bitmap;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/*!
 *  Note class containing all basic info for a note including
 *  a helper to set the timedate for updated/created to now
 */
public class Note {
    private int id;
    private String text;
    private String created;
    private String updated;
    private ArrayList<String> tags;

    /// ATTACHMENTS INFO
    private String filename; // like test.png
    private String filetype; // like "png"
    private String path;    // like dir/dir/test.png

    private Bitmap bitmap; // only if theres a photo

    private int remoteID;
    private int toSync;
    private int toDelete;

    public Note(){
        this.id = -1;
        this.text = "";
        this.created = "";
        this.updated = "";
        this.tags = new ArrayList<String>();
        this.remoteID = 0;
        this.toDelete = 0;
        this.toSync = 0;
        this.path = null;
        this.bitmap = null;
    }

    //---------------- SETTERS ----------------

    public void setID(int id){ this.id = id; }

    public void setText(String text){
        this.text = text;
    }

    public void setCreated(String created){
        this.created = created;
    }

    /*!
     *  Sets the created TimeDate to the current TimeDate
     */
    public void createNow(){
        this.created = now();
    }

    public void setUpdated(String updated){
        this.updated = updated;
    }

    /*!
     *  Sets the updated TimeDate to the current TimeDate
     */
    public void updateNow(){
        this.updated = now();
    }


    //ATTACHMENTS
    public void setPath(String path) {
        this.path = path;
    }
    public void setBitmap(Bitmap bitmap){ this.bitmap = bitmap; }
    public void setFilename(String filename){ this.filename = filename; }
    public void setFiletype(String filetype) { this.filetype = filetype; }

    public void setRemoteID(int remoteID){ this.remoteID = remoteID; }

    public void setToSync(int toSync){ this.toSync = toSync; }

    public void setToDelete(int toDelete){ this.toDelete = toDelete; }

    public void setTags(ArrayList<String> tags){ this.tags = tags; }

    //---------------- GETTERS ----------------

    public String getText(){ return this.text; }

    public int getID(){
        return this.id;
    }

    public String getCreated(){
        return this.created;
    }

    public String getUpdated(){
        return this.updated;
    }

    /*!
     *  \return ArrayList<String>| list of all the tags associated with the note
     */
    public ArrayList<String> getTags(){
        return this.tags;
    }

    //ATTACHMENTS
    public String getPath(){
        return this.path;
    }
    public Bitmap getBitmap() { return this.bitmap; }
    public String getFilename() { return this.filename; }
    public String getFiletype() { return this.filetype; }

    public int getRemoteID(){ return this.remoteID; }

    public int getToSync(){ return this.toSync; }

    public int getToDelete(){ return this.toDelete; }

    public String toString(){
        return "" +
                "ID: " + this.id + "\n" +
                "CRE: " + this.created + "\n" +
                "UPD: " + this.updated + "\n" +
                "FN: " + this.filename + "\n" +
                "FT: " + this.filetype + "\n" +
                "PA: " + this.path + "\n" +
                "RID: " + this.remoteID + "\n" +
                "SYN: " + this.toSync + "\n" +
                "DEL: " + this.toDelete + "\n";
    }

    //---------------- HELPERS ----------------

    /*!
     *  assumes tag has already been checked for validity (alphanumeric or _)
     *
     *  \param tag| string of new taf to add
     */
    public void addTag(String tag){
        this.tags.add(tag);
    }

    /*!
     *  Used to generate a list of tags that can be displayed as a single String
     *
     *  \return String| list of tags in plaintext
     */
    public String tagsToString(){
        String stringOfTags = "";

        for(int i=0; i<this.tags.size(); i++){
            stringOfTags += this.tags.get(i) + " ";
        }

        return stringOfTags;
    }

    /*!
     *  Used to generate a list of tags, prefixed with a pound sign (hashtag),
     *  that can be displayed as a single string
     *
     *  \return String| list of tags in plaintext
     */
    public String tagsToHashtags(){
        String stringOfTags = "";

        for(int i=0; i<this.tags.size(); i++){
            stringOfTags += "#" + this.tags.get(i) + " ";
        }

        return stringOfTags;
    }

    /*!
     *  Used to generate a mySQL-like timedate string of right now
     *  in format of YYYY-MM-DD HH:MM:SS
     *
     *  \return String| current timeDate string
     */
    public String now(){
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date date = new Date();
        return dateFormat.format(date); //2014-08-06 15:59:48
    }
}
