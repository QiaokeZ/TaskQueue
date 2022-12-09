package com.zq;

import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.progressindicator.LinearProgressIndicator;
import com.zq.databinding.ActivityMainBinding;
import com.zq.taskqueue.TaskQueue;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends AppCompatActivity implements DownloadTask.OnUpdateListener {

    ActivityMainBinding binding;
    private MyAdpter myAdpter;
    private List<Download> downloads = new ArrayList<>();
    private Map<String, Integer> indexKeyedById = new HashMap<>();
    private TaskQueue<DownloadTask> queue = new TaskQueue<>();
    private Handler handler = new Handler();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        myAdpter = new MyAdpter();
        binding.listView.setAdapter(myAdpter);

        binding.ibLeft.setOnClickListener(view -> {
            long count = queue.getMaxTaskCount();
            queue.setMaxTaskCount(--count);
            binding.tvCount.setText(queue.getMaxTaskCount() + "");
        });

        binding.ibRight.setOnClickListener(view -> {
            long count = queue.getMaxTaskCount();
            queue.setMaxTaskCount(++count);
            binding.tvCount.setText(queue.getMaxTaskCount() + "");
        });

        binding.tvStartAllTasks.setOnClickListener(view -> {
            if (binding.tvStartAllTasks.getText().toString().equals("全部开始")) {
                //开始所有任务
                binding.tvStartAllTasks.setText("全部暂停");
                queue.startAllTasks();
                for (Download download : downloads) {
                    download.state = 0;
                }
                myAdpter.notifyDataSetChanged();
            } else if (binding.tvStartAllTasks.getText().toString().equals("全部暂停")) {
                //暂停所有任务
                binding.tvStartAllTasks.setText("全部开始");
                queue.pauseAllTasks();
                for (Download download : downloads) {
                    download.state = 2;
                }
                myAdpter.notifyDataSetChanged();
            }
        });

        binding.tvRemoveAllTasks.setOnClickListener(view -> {
            //删除所有任务
            queue.removeAllTasks();
            downloads.clear();
            indexKeyedById.clear();
            myAdpter.notifyDataSetChanged();
        });

        queue.setMaxTaskCount(1); //设置最大任务数 注意:-1 代表执行所有任务
        for (int i = 0; i < 20; i++) {
            String id = i + "";
            Download download = new Download();
            download.id = id;
            downloads.add(download);

            //(优化)根据任务id快速找到对应索引，用来刷新指定的ViewHolder
            indexKeyedById.put(id, i);

            //创建任务
            DownloadTask task = new DownloadTask();
            task.setDownload(download);
            task.setOnUpdateListener(this);

            //添加任务
            queue.add(task, id);

            //执行任务
            queue.startTask(id);
        }
        myAdpter.notifyDataSetChanged();
    }

    public void refreshIndexKeydById() {
        indexKeyedById.clear();
        for (int i = 0; i < downloads.size(); i++) {
            Download download = downloads.get(i);
            indexKeyedById.put(download.id, i);
        }
    }

    @Override
    public void onUpdate(Download download) {
        //(优化)根据任务id快速找到对应索引，用来刷新指定的ViewHolder
        int index = indexKeyedById.get(download.id);
        if (downloads.size() > index) {
            handler.post(() -> myAdpter.notifyItemChanged(binding.listView, index));
        }
    }

    class MyAdpter extends BaseListViewAdapter<ViewHolder> {

        @Override
        protected ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(MainActivity.this).inflate(R.layout.item_task_download,
                    parent, false);
            ViewHolder viewHolder = new ViewHolder(view);
            return viewHolder;
        }

        @Override
        protected void onBindViewHolder(ViewHolder holder, int position) {
            Download download = downloads.get(position);
            holder.name.setText(download.id);
            int v = (int) (100 * download.progress);
            holder.progress.setProgress(v);
            //0=等待中 1=进行中 2=暂停中 3=已完成
            if (download.state == 0) {
                holder.icon.setImageResource(R.drawable.ic_baseline_access_time_24);
            } else if (download.state == 1) {
                holder.icon.setImageResource(R.drawable.ic_baseline_pause_circle_filled_24);
            } else if (download.state == 2) {
                holder.icon.setImageResource(R.drawable.ic_baseline_not_started_24);
            } else if (download.state == 3) {
                holder.icon.setImageResource(R.drawable.ic_baseline_done_24);
            }
            holder.icon.setOnClickListener(view -> {
                if (download.state == 0 || download.state == 1) {
                    //暂停任务
                    queue.pauseTask(download.id);
                    download.state = 2;
                    holder.icon.setImageResource(R.drawable.ic_baseline_not_started_24);
                } else if (download.state == 2) {
                    //启动任务
                    queue.startTask(download.id);
                    download.state = 1;
                    holder.icon.setImageResource(R.drawable.ic_baseline_pause_circle_filled_24);
                }
            });
        }

        @Override
        public int getCount() {
            return downloads.size();
        }

        @Override
        public Object getItem(int i) {
            return downloads.get(i);
        }
    }

    static final class ViewHolder extends BaseListViewAdapter.BaseListViewHolder {

        public TextView name;
        public ImageView icon;
        public LinearProgressIndicator progress;

        public ViewHolder(View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.tv_name);
            icon = itemView.findViewById(R.id.ib_state);
            progress = itemView.findViewById(R.id.progress);
        }
    }
}