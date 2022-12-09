package com.zq.taskqueue;

public abstract class Task {

    private Runnable finishCallback;
    private TaskQueue.TaskState taskState;
    private String id;
    private boolean enabled;

    protected void onCreate() {
    }

    protected void onStart() {
    }

    protected void onPause() {
    }

    protected void onDestroy() {
    }

    protected final void finish() {
        this.taskState = TaskQueue.TaskState.FINISHED;
        finishCallback.run();
    }

    public TaskQueue.TaskState getTaskState() {
        return taskState;
    }

    public String getId() {
        return id;
    }

    void performOnCreate() {
        this.taskState = TaskQueue.TaskState.WAITING;
        onCreate();
    }

    void performOnStart() {
        this.taskState = TaskQueue.TaskState.RUNNING;
        onStart();
    }

    void performOnPause() {
        this.taskState = TaskQueue.TaskState.PAUSED;
        onPause();
    }

    void set(String id, Runnable finishCallback) {
        this.id = id;
        this.finishCallback = finishCallback;
        performOnCreate();
    }

    void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    boolean isEnabled() {
        return enabled;
    }
}
