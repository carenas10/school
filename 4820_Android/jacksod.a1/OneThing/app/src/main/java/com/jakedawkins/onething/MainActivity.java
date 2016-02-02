/*

 */

package com.jakedawkins.onething;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import java.util.concurrent.TimeUnit;
import android.widget.Toast;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

    //queue of timers
    ArrayList<TimerTuple> timerList = null;

    private TextView display = null;
    private static final String FORMAT = "%02d:%02d";
    private CountDownTimer timer = null;

    private boolean isRunning;
    private boolean timerIsDisplayed;

    private long timeLeft;
    private EditText editTitle;
    private EditText editTime;

    private TextView currentTitle;
    private TextView nextTitle;


    public class TimerTuple {
        protected long time;
        protected String name;

        public TimerTuple(){
            this.time = 0;
            this.name = "";
        }

        public TimerTuple(long time, String name){
            this.time = time;
            this.name = name;
        }

        public void setTime(long time){
            this.time = time;
        }
        public void setName(String name){
            this.name = name;
        }

        public long getTime(){
            return this.time;
        }
        public String getName() {
            return this.name;
        }
    }


    //user clicks button to add a timer to the queue
    public void newTimer(View view){
        //hide the keyboard first
        InputMethodManager imm = (InputMethodManager)getSystemService(Context.
                INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);

        String message = "";

        //check to make sure the name box has a name for the new timer
        if(editTitle.getText().toString().length() == 0){
            message = "You must enter a title";//toast the error
        } else {

            //if there is a title, find out which time button they pressed
            long time = 0;

            if(view.getId() == R.id.button){ //5 minute button
                time = 300000;
            }
            else if(view.getId() == R.id.button2){ //10 minute button
                time = 600000;
            }
            else if(view.getId() == R.id.button3){ //custom button
                time = 60000 * Integer.parseInt(editTime.getText().toString());
            }

            String title = editTitle.getText().toString();
            editTitle.setText("");

            if(timerIsDisplayed){
                if(timerList.size() == 0) nextTitle.setText("NEXT: " + title);
                timerList.add(new TimerTuple(time, title));
            } else {
                timeLeft = time;
                currentTitle.setText(title);
                display.setText(""+String.format(FORMAT,
                        TimeUnit.MILLISECONDS.toMinutes(time),
                        TimeUnit.MILLISECONDS.toSeconds(time) - TimeUnit.MINUTES.toSeconds(
                                TimeUnit.MILLISECONDS.toMinutes(time))));
                timerIsDisplayed = true;
            }

            message = "Timer added to queue";
        }

        //toast the user
        Toast.makeText(getApplicationContext(),message, Toast.LENGTH_SHORT).show();
    }

    //user hits button to advance the queue
    public void nextTimer(View view){
        //stop current timer, if there is one running
        if(isRunning) {
            timer.cancel();
            isRunning = false;
            timerIsDisplayed = true;
            timeLeft = 0;
            ImageView playPauseButton = (ImageView)findViewById(R.id.playPauseButton);
            playPauseButton.setImageResource(R.drawable.play);
        }

        //no more timers
        if(timerList.size() == 0){
            //no timers left. toast the user
            display.setText("DONE");
            currentTitle.setText("");
            Toast.makeText(getApplicationContext(),"There are no more timers", Toast.LENGTH_SHORT).show();
        }

        //if there is another timer on the queue
        //dequeue the next timer and start it
        else {
            TimerTuple nextTimer = timerList.remove(0);
            timeLeft = nextTimer.getTime();
            currentTitle.setText(nextTimer.getName());
            display.setText(""+String.format(FORMAT,
                    TimeUnit.MILLISECONDS.toMinutes(timeLeft),
                    TimeUnit.MILLISECONDS.toSeconds(timeLeft) - TimeUnit.MINUTES.toSeconds(
                            TimeUnit.MILLISECONDS.toMinutes(timeLeft))));

            //startTimer(nextTimer.getTime());
            timerIsDisplayed = true;

            //set next title text
            if(timerList.size() != 0) nextTitle.setText("NEXT: " + timerList.get(0).getName());
            else nextTitle.setText("");
        }

    }

    public void playPauseTimer(View view){
        ImageView playPauseButton = (ImageView)findViewById(R.id.playPauseButton);

        if(this.isRunning){
            //to pause: cancel the running timer.
            //time left already logged on tick
            timer.cancel();
            isRunning = false;
            playPauseButton.setImageResource(R.drawable.play);

        } else if (!this.isRunning && timeLeft > 0) {
            //if the counter is paused, resume by starting a new timer
            //with last logged remaining time
            startTimer(timeLeft);
            isRunning = true;
            playPauseButton.setImageResource(R.drawable.pause);
        } else {
            Toast.makeText(getApplicationContext(),"You must make a timer first", Toast.LENGTH_SHORT).show();
        }
    }

    public void startTimer(long time){
        //stop old timer if still running
        if(this.timer != null){
            this.timer.cancel();
            isRunning = false;
        }

        //start a new timer
        this.timer = new CountDownTimer(time,500){
            public void onTick(long millisUntilFinished){

                //log remaining time in case we need to cancel
                timeLeft = millisUntilFinished;

                //ouput time left to user
                display.setText(""+String.format(FORMAT,
                        TimeUnit.MILLISECONDS.toMinutes(timeLeft),
                        TimeUnit.MILLISECONDS.toSeconds(timeLeft) - TimeUnit.MINUTES.toSeconds(
                                TimeUnit.MILLISECONDS.toMinutes(timeLeft))));
            }

            public void onFinish(){
                display.setText("DONE");
            }
        }.start();

        this.isRunning = true;
        this.timerIsDisplayed = true;
    }

    public void toInfoActivity(MenuItem item){
        startActivity(new Intent(getApplicationContext(), InfoActivity.class));
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        display =  (TextView)findViewById(R.id.timerDisplay);

        currentTitle = (TextView)findViewById(R.id.runningTimerName);
        nextTitle = (TextView)findViewById(R.id.nextTimerName);

        currentTitle.setText("");
        nextTitle.setText("");

        timerList =  new ArrayList<TimerTuple>();
        isRunning = false;
        timeLeft = 0;

        editTitle = (EditText)findViewById(R.id.editTitle);
        editTime = (EditText)findViewById(R.id.editTime);

        timerIsDisplayed = false;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        Log.i("info","button pressed");

        return super.onOptionsItemSelected(item);
    }

    //used to hide the keyboard
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        InputMethodManager imm = (InputMethodManager)getSystemService(Context.
                INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        return true;
    }
}
