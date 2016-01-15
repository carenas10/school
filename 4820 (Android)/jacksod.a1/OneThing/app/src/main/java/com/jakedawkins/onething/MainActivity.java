package com.jakedawkins.onething;

import android.os.Bundle;
import android.os.CountDownTimer;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import java.util.concurrent.TimeUnit;
import android.widget.Toast;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

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

    //queue of timers
    ArrayList<TimerTuple> timerList = null;
    private TextView display = null;
    private static final String FORMAT = "%02d:%02d";
    private CountDownTimer timer = null;

    private boolean isRunning;
    private boolean timerIsDisplayed;

    private long timeLeft;
    private EditText editTitle;

    //user clicks button to add a timer to the queue
    public void newTimer(View view){
        Log.i("dbg","in newTimer");
        //check to make sure the name box has a name for the new timer
        if(editTitle.getText().toString().length() == 0){
            Log.i("dbg len","length 0");
            String message = "You must enter a title";//toast error
        } else {
            Log.i("dbg len","length !0");
            //if there is a title, find out which time button they pressed
            long time = 0;

            if(view.getId() == R.id.button) time = 300000;
            else if(view.getId() == R.id.button2) time = 600000;
            else { //custom button
                time = 10000;
            }
            Log.i("dbg time",Long.toString(time));

            String title = editTitle.getText().toString();
            Log.i("dbg title",title);

            //add the new timer to the queue
            Log.i("dbg list",Integer.toString(timerList.size()));
            timerList.add(new TimerTuple(time, title));
            Log.i("dbg list", Integer.toString(timerList.size()));
            if(timerList.size() == 1 && !timerIsDisplayed){
                timeLeft = time;
                display.setText(""+String.format(FORMAT,
                        TimeUnit.MILLISECONDS.toMinutes(time) - TimeUnit.HOURS.toMinutes(
                                TimeUnit.MILLISECONDS.toHours(time)),
                        TimeUnit.MILLISECONDS.toSeconds(time) - TimeUnit.MINUTES.toSeconds(
                                TimeUnit.MILLISECONDS.toMinutes(time))));
            }

            String message = "Timer added to queue";
        }




        //toast the user
    }

    //user hits button to advance the queue
    public void nextTimer(View view){
        //no more timers
        if(timerList.size() == 0){
            //no timers left. toast the user
            display.setText("DONE");
            Toast.makeText(getApplicationContext(),"There are no more timers", Toast.LENGTH_LONG).show();
            isRunning = false;
            timerIsDisplayed = false;
        }

        //stop current timer, if there is one running
        if(isRunning) {
            timer.cancel();
            isRunning = false;
            timerIsDisplayed = true;
        }

        //if there is another timer on the queue
        //dequeue the next timer and start it
        else {
            TimerTuple nextTimer = timerList.remove(0);
            timeLeft = nextTimer.getTime();
            display.setText(""+String.format(FORMAT,
                    TimeUnit.MILLISECONDS.toMinutes(timeLeft) - TimeUnit.HOURS.toMinutes(
                            TimeUnit.MILLISECONDS.toHours(timeLeft)),
                    TimeUnit.MILLISECONDS.toSeconds(timeLeft) - TimeUnit.MINUTES.toSeconds(
                            TimeUnit.MILLISECONDS.toMinutes(timeLeft))));

            //startTimer(nextTimer.getTime());
            timerIsDisplayed = true;
        }

    }

    public void playPauseTimer(View view){

        if(this.isRunning){
            //to pause: cancel the running timer.
            //time left already logged on tick
            timer.cancel();
            isRunning = false;
        } else {
            //if the counter is paused, resume by starting a new timer
            //with last logged remaining time
            startTimer(timeLeft);
            isRunning = true;
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
                        TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished) - TimeUnit.HOURS.toMinutes(
                                TimeUnit.MILLISECONDS.toHours(millisUntilFinished)),
                        TimeUnit.MILLISECONDS.toSeconds(millisUntilFinished) - TimeUnit.MINUTES.toSeconds(
                                TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished))));
            }

            public void onFinish(){
                display.setText("DONE");
            }
        }.start();

        this.isRunning = true;
        this.timerIsDisplayed = true;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        display =  (TextView)findViewById(R.id.timerDisplay);
        timerList =  new ArrayList<TimerTuple>();
        isRunning = false;
        timeLeft = 0;
        editTitle = (EditText)findViewById(R.id.editTitle);
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

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
