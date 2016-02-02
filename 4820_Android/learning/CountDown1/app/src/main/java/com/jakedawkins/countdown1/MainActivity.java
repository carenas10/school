/*
*   Sources
*   - How to countdown: https://stackoverflow.com/questions/10032003/how-to-make-a-countdown-timer-in-android
*
 */

package com.jakedawkins.countdown1;

import android.os.Bundle;
import android.os.CountDownTimer;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.TextView;
import java.util.concurrent.TimeUnit;

public class MainActivity extends AppCompatActivity {

    private static final String FORMAT = "%02d:%02d:%02d";

    int seconds , minutes;

    private CountDownTimer timer = null;


    public void startTimer(View view){
        final TextView display =  (TextView) findViewById(R.id.display);
        Button b = (Button)view;
        String text = b.getText().toString();


        int time = 0;
        if(text.equals("1 Minute")) time = 60000;
        else if(text.equals("5 Minutes")) time = 300000;

        //if a timer is running, stop it before starting a new one
        if (timer != null) {
            timer.cancel();
        }

        //start a new timer
        timer = new CountDownTimer(time,500){
            public void onTick(long millisUntilFinished){
                display.setText(""+String.format(FORMAT,
                        TimeUnit.MILLISECONDS.toHours(millisUntilFinished),
                        TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished) - TimeUnit.HOURS.toMinutes(
                                TimeUnit.MILLISECONDS.toHours(millisUntilFinished)),
                        TimeUnit.MILLISECONDS.toSeconds(millisUntilFinished) - TimeUnit.MINUTES.toSeconds(
                                TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished))));
            }

            public void onFinish(){
                display.setText("Done");
            }
        }.start();
    }

    public void stopTimer(View view){
        if(timer != null){
            timer.cancel();
        }

        TextView display =  (TextView) findViewById(R.id.display);
        display.setText("00:00:00");

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        /*
        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });*/
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
