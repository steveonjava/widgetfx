/**
 * Copyright (c) 1999 - 2008 Inovis, Inc.
 *
 * ALL RIGHTS RESERVED.  NO PART OF THIS WORK MAY BE USED OR
 * REPRODUCED IN ANY FORM WITHOUT THE PERMISSION IN WRITING
 * OF INOVIS, INC.
 */

package rallyws;

public enum TaskStateEnum {
    Defined ("Defined", "D"),
    InProgress ("In-Progress", "P"),
    Completed ("Completed", "C");

    private String stringValue;
    private String codeValue;

    TaskStateEnum(String stringValue, String codeValue) {
        this.stringValue = stringValue;
        this.codeValue = codeValue;
    }

    public String toString() {
        return stringValue;
    }

    public String getCodeValue(){
        return codeValue;
    }

    public static TaskStateEnum fromState(String state){
        if (Defined.toString().equals(state)){
            return Defined;
        } else if (InProgress.toString().equals(state)){
            return InProgress;
        } else if (Completed.toString().equals(state)){
            return Completed;
        } else {
            return null;   
        }
    }

}