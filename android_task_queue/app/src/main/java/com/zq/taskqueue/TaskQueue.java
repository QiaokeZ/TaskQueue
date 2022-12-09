package com.zq.taskqueue;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

public class TaskQueue<T extends Task> {

    public enum TaskState {
        WAITING,
        RUNNING,
        PAUSED,
        FINISHED,
    }

    public static final long DEFAULT_MAX_TASK_COUNT = -1L;
    private Map<String, T> taskKeyedById;
    private long maxTaskCount;
    private boolean enabled;

    public TaskQueue() {
        this.enabled = true;
        this.maxTaskCount = DEFAULT_MAX_TASK_COUNT;
        this.taskKeyedById = new LinkedHashMap<>();
    }

    public boolean contains(String id) {
        return taskKeyedById.get(id) != null;
    }

    public synchronized boolean add(T task, String id) {
        if (contains(id)) return false;
        task.set(id, () -> {
            removeTask(id);
        });
        taskKeyedById.put(id, task);
        return true;
    }

    public T get(String id) {
        return taskKeyedById.get(id);
    }

    public void performBatch(Runnable runnable) {
        if (runnable != null) {
            enabled = false;
            runnable.run();
            enabled = true;
            execute();
        }
    }

    public synchronized void startTask(String id) {
        Task task = get(id);
        if (task != null) {
            task.setEnabled(true);
            execute();
        }
    }

    public synchronized void pauseTask(String id) {
        Task task = get(id);
        if (task != null) {
            task.setEnabled(false);
            execute();
        }
    }

    public synchronized void removeTask(String id) {
        Task task = get(id);
        if (task != null) {
            task.onDestroy();
            taskKeyedById.remove(id);
            execute();
        }
    }

    public void startAllTasks() {
        performBatch(() -> {
            for (T task : getTasks()) {
                task.setEnabled(true);
            }
        });
    }

    public void pauseAllTasks() {
        performBatch(() -> {
            for (T task : getTasks()) {
                task.setEnabled(false);
            }
        });
    }

    public void removeAllTasks() {
        performBatch(() -> {
            Iterator<Map.Entry<String, T>> iterator = taskKeyedById.entrySet().iterator();
            while (iterator.hasNext()) {
                Map.Entry<String, T> entry = iterator.next();
                T task = entry.getValue();
                task.onDestroy();
                iterator.remove();
            }
        });
    }

    public void setMaxTaskCount(long value) {
        if (maxTaskCount != value) {
            maxTaskCount = Math.max(DEFAULT_MAX_TASK_COUNT, value);
            execute();
        }
    }

    public long getMaxTaskCount() {
        return maxTaskCount;
    }

    public Collection<T> getTasks() {
        return taskKeyedById.values();
    }

    private void execute() {
        if (!enabled) return;
        for (T task : getTasks()) {
            if (!task.isEnabled() && task.getTaskState() == TaskState.RUNNING) {
                task.performOnPause();
            }
            if (maxTaskCount != DEFAULT_MAX_TASK_COUNT) {
                if (maxTaskCount < activeCount() && task.getTaskState() == TaskState.RUNNING) {
                    task.performOnPause();
                }
            }
        }
        for (T task : getTasks()) {
            if (belowMaxTask() && task.isEnabled() && task.getTaskState() != TaskState.RUNNING) {
                task.performOnStart();
            }
        }
    }

    private boolean belowMaxTask() {
        if (maxTaskCount == DEFAULT_MAX_TASK_COUNT) {
            return true;
        }
        return activeCount() < maxTaskCount;
    }

    private long activeCount() {
        long count = 0;
        for (T task : getTasks()) {
            if (task.getTaskState() == TaskState.RUNNING) {
                count++;
            }
        }
        return count;
    }
}