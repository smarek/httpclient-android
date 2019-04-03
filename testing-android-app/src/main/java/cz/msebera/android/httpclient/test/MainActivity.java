package cz.msebera.android.httpclient.test;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import java.lang.ref.WeakReference;

import cz.msebera.android.httpclient.HttpHost;
import cz.msebera.android.httpclient.client.methods.CloseableHttpResponse;
import cz.msebera.android.httpclient.client.methods.HttpGet;
import cz.msebera.android.httpclient.impl.client.CloseableHttpClient;
import cz.msebera.android.httpclient.impl.client.HttpClients;
import cz.msebera.android.httpclient.util.EntityUtils;

public class MainActivity extends Activity {

    TextView status_text;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        status_text = (TextView) findViewById(R.id.status_text);
        new HttpTest(this).execute();
    }

    static class HttpTest extends AsyncTask<Void, Void, String> {
        WeakReference<MainActivity> link;

        HttpTest(MainActivity ma) {
            super();
            this.link = new WeakReference<>(ma);
        }

        @Override
        protected String doInBackground(Void... voids) {
            String ret = null;
            CloseableHttpClient chc = HttpClients.createDefault();
            try {
                CloseableHttpResponse chr = chc.execute(HttpHost.create("https://httpbin.org"), new HttpGet("/headers"));
                ret = EntityUtils.toString(chr.getEntity());
                chr.close();
                chc.close();
            } catch (Exception e) {
                Log.e("HttpTest", e.getMessage(), e);
                ret = e.getMessage();
            }
            return ret;
        }

        @Override
        protected void onPostExecute(String s) {
            if (this.link.get() != null) {
                this.link.get().status_text.setText(s);
                this.link.clear();
            }
        }
    }
}
