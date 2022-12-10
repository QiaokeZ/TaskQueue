package com.zq.taskqueue;

public abstract class Task {

    private Runnable finishCallback;
    private TaskState taskState;
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
        this.taskState = TaskState.FINISHED;
        finishCallback.run();
    }

    public TaskState getTaskState() {
        return taskState;
    }

    public String getId() {
        return id;
    }

    void performOnWait() {
        this.taskState = TaskState.WAITING;
        onWait();
    }

    void performOnStart() {
        this.taskState = TaskState.RUNNING;
        onStart();
    }

    void performOnPause() {
        this.taskState = TaskState.PAUSED;
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
