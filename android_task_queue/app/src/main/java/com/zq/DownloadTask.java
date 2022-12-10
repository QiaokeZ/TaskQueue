package com.zq;

import android.util.Log;

import com.zq.taskqueue.Task;

import java.util.Timer;
import java.util.TimerTask;

public class DownloadTask extends Task {

    public static final String TAG = "DownloadTask";

    public interface OnUpdateListener {
        void onUpdate(Download download);
    }

    private Download download;
    private OnUpdateListener updateListener;
    private Timer timer;
    private TimerTask timerTask;
    private int timeCount;

    public void setDownload(Download download) {
        this.download = download;
    }

    public void setOnUpdateListener(OnUpdateListener updateListener) {
        this.updateListener = updateListener;
    }

    @Override
    protected void onWait() {
        super.onWait();
        Log.i(TAG, "任务:" + getId() + " 已创建");
        download.state = 0;
        updateListener.onUpdate(download);
    }

    @Override
    protected void onStart() {
        super.onStart();
        Log.i(TAG, "任务:" + getId() + " 下载中");
        timer = new Timer();
        timerTask = new TimerTask() {
            @Override
            public void run() {
                timeCount++;
                download.state = 1;
                download.progress = (float) (1.0 * timeCount / 200);
                if (download.progress >= 1.0) {  //任务完成
                    download.state = 3;
                    //结束当前任务
                    finish();
                }
                updateListener.onUpdate(download);
                //0=等待中 1=进行中 2=暂停中 3=已完成
            }
        };
        timer.schedule(timerTask, 0, 100);
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.i(TAG, "任务:" + getId() + " 暂停中");
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
        download.state = 2;
        updateListener.onUpdate(download);
    }

    @Override
    protected void onDispose() {
        super.onDispose();
        //释放资源
        Log.i(TAG, "任务:" + getId() + " 已销毁");
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
    }
}
