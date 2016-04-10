package com.jakedawkins.notes;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.RequestFuture;
import com.android.volley.toolbox.StringRequest;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class LoginActivity extends AppCompatActivity {

    EditText usernameField;
    EditText passwordfield;

    public void loginPressed(View view){
        String username = usernameField.getText().toString();
        String password = passwordfield.getText().toString();

        /// Validate the fields first
        /// one of the fields are empty
        if(username.length() == 0 || password.length() == 0){
            Toast toast = Toast.makeText(this, "Both fields must be filled", Toast.LENGTH_LONG);
            toast.show();
        } else {
            RemoteDB.getInstance().setUsername(username);
            RemoteDB.getInstance().setPassword(password);
            RemoteDB.getInstance().login();

            if(RemoteDB.getInstance().loggedIn()){
                SharedPreferences settings = getSharedPreferences("UserInfoPrefs", 0);

                // We need an Editor object to make preference changes.
                SharedPreferences.Editor editor = settings.edit();
                editor.putInt("userID", RemoteDB.getInstance().getUserID());

                /// Commit the edits!
                editor.commit();

                finish();
            } else {
                Toast toast = Toast.makeText(this, "Login Failed. Please Try Again.", Toast.LENGTH_LONG);
                toast.show();
            }
        }
    }

    /*
    public void newUserPressed(View view){
        String username = usernameField.getText().toString();
        String password = passwordfield.getText().toString();

        /// Validate the fields first
        /// one of the fields are empty
        if(username.length() == 0 || password.length() == 0){
            Toast toast = Toast.makeText(this, "Both fields must be filled", Toast.LENGTH_LONG);
            toast.show();
        } else {
            RemoteDB.getInstance().setUsername(username);
            RemoteDB.getInstance().setPassword(password);
            RemoteDB.getInstance().login();

            if(RemoteDB.getInstance().loggedIn()){
                SharedPreferences settings = getSharedPreferences("UserInfoPrefs", 0);

                // We need an Editor object to make preference changes.
                SharedPreferences.Editor editor = settings.edit();
                editor.putInt("userID", RemoteDB.getInstance().getUserID());

                /// Commit the edits!
                editor.commit();

                finish();
            } else {
                Toast toast = Toast.makeText(this, "Login Failed. Please Try Again.", Toast.LENGTH_LONG);
                toast.show();
            }
        }
    }*/

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        usernameField = (EditText)findViewById(R.id.username);
        passwordfield = (EditText)findViewById(R.id.password);
    }
}
