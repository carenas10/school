package com.jakedawkins.notes;

import java.util.ArrayList;

/**
 * Created by Jake on 2/1/16.
 */
public class Note {
    private String text;
    private ArrayList<String> tags;

    public Note(){
        this.text = "";
        this.tags = new ArrayList<String>();
    }

    public void setText(String text){
        this.text = text;
    }

    public void addTag(String tag){
        this.tags.add(tag);
    }

    public String getText(){
        return this.text;
    }

    public ArrayList<String> getTags(){
        return this.tags;
    }

    public String tagsToString(){
        String stringOfTags = "";

        for(int i=0; i<this.tags.size(); i++){
            stringOfTags += this.tags.get(i) + " ";
        }

        return stringOfTags;
    }

    public String tagsToHashtags(){
        String stringOfTags = "";

        for(int i=0; i<this.tags.size(); i++){
            stringOfTags += "#" + this.tags.get(i) + " ";
        }

        return stringOfTags;
    }



}
