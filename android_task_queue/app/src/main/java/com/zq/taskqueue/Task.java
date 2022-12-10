package com.zq.taskqueue;

public abstract class Task {

    private Runnable finishCallback;
    private TaskQueue.TaskState taskState;
    private String id;
    private boolean enabled;

    protected void onWait() {
    }

    protected void onStart() {
    }

    protected void onPause() {
    }

    protected void onDispose() {
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

    void performOnWait() {
        this.taskState = TaskQueue.TaskState.WAITING;
        onWait();
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
        performOnWait();
    }

    void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    boolean isEnabled() {
        return enabled;
    }
}
