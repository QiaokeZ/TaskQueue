package com.zq;

public class Download {

    public int state = 0; //0=等待中 1=进行中 2=暂停中 3=已完成
    public float progress; //进度
    public String id;
}
