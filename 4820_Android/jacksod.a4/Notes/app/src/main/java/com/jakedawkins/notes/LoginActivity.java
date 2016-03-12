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

    EditText usernameField;// = (EditText)findViewById(R.id.username);
    EditText passwordfield;// = (EditText)findViewById(R.id.password);

    public void loginPressed(View view){
        String username = usernameField.getText().toString();
        String password = passwordfield.getText().toString();

        //one of the fields are empty
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

                // Commit the edits!
                editor.commit();

                finish();
            } else {
                Toast toast = Toast.makeText(this, "Login Failed. Please Try Again.", Toast.LENGTH_LONG);
                toast.show();
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        usernameField = (EditText)findViewById(R.id.username);
        passwordfield = (EditText)findViewById(R.id.password);
    }

    //DO NOT USE
    public boolean login(){
        final String username = usernameField.getText().toString();
        final String password = passwordfield.getText().toString();
        String URL = RemoteDB.getInstance().getBaseURL() + "users/" + username;
        Log.i("URL",URL);

        RequestFuture<String> future = RequestFuture.newFuture();
        StringRequest request = new StringRequest(Request.Method.POST, URL, future, future)        {
            @Override
            protected Map<String, String> getParams()
            {
                Map<String, String> params = new HashMap<String, String>();
                params.put("username", username);
                params.put("password", password);
                return params;
            }
        };
        RemoteDB.getInstance().getRequestQueue().add(request);

        try {
            //blocks for max of 3 seconds
            String response = future.get(3, TimeUnit.SECONDS);
            Log.i("LOGIN_RESPONSE_SYNC",response);
            return true;
        } catch (InterruptedException e) {
            // exception handling
        } catch (ExecutionException e) {
            // exception handling
            Log.i("EXECUTION_EXCEPTION","In Login()");
        } catch (TimeoutException e){
            Log.i("TIMEOUT","Login Timed out");

        }
        return false;
    }
}
