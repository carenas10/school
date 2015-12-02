import java.io.IOException;
import java.util.*;
        
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.conf.*;

import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.*;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import org.json.*;
import java.lang.String;

public class Unique {
        
 public static class Map extends Mapper<LongWritable, Text, Text, IntWritable> {
    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();
        
    public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        try {
            JSONObject data = new JSONObject(value.toString());
            JSONObject tweetent = data.getJSONObject("twitter_entities");
            JSONArray hashtags = new JSONArray(tweetent.getJSONArray("hashtags").toString());
            
            for(int i = 0; i < hashtags.length(); i++) {
                JSONObject hText = hashtags.getJSONObject(i);
                String text = hText.getString("text");
                word.set(text);
                context.write(word, one);
            }
        } catch(Exception ex1) {

        }
    }
 } 
        
 public static class Reduce extends Reducer<Text, IntWritable, Text, IntWritable> {

    public void reduce(Text key, Iterable<IntWritable> values, Context context) 
      throws IOException, InterruptedException {
        int sum = 0;
        for (IntWritable val : values) {
            sum += val.get();
        }
        context.write(key, new IntWritable(sum));
    }
 }
        
 public static void main(String[] args) throws Exception {
    
    Logger logger = Logger.getLogger(WordCount.class); 
    PropertyConfigurator.configure("/home/lngo/software/hadoop-2.6.0/etc/hadoop/log4j.properties");
    Logger.getRootLogger().setLevel(Level.INFO);

    Configuration conf = new Configuration();
    conf.set("mapred.reduce.tasks","4");
    
    Job job = new Job(conf, "wordcount");
    job.setJarByClass(WordCount.class);
    
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
        
    job.setMapperClass(Map.class);
    job.setReducerClass(Reduce.class);
        
    job.setInputFormatClass(TextInputFormat.class);
    job.setOutputFormatClass(TextOutputFormat.class);
        
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
        
    job.waitForCompletion(true);
 }
        
}