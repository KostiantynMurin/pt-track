/**
 * @description  : Class that is used for return value for most of methods
 * @author       : Kostiantyn Murin
 * @date         : 02-22-2025
**/

public class Response {
    
    /** @description status - Type: String - 'success', 'error' or 'warning' - used for displaying result of action */
    @AuraEnabled 
    public String status      { get; set; }
    /** @description message - Type: String - contain message about result of action */
    @AuraEnabled 
    public String message     { get; set; }
    /** @description responseObj - Type: depend on method - return object that is result of action */
    @AuraEnabled 
    public Object responseObj { get; set; }
    /** @description responseObj - Type: Boolean - used for displaying if operation was success */
    @AuraEnabled
    public Boolean isSuccess  { get; set; }
    
    /**
    * @description Default Constructor
    * @author Kostiantyn Murin | 02-22-2025 
    **/
    public Response() {
        this.isSuccess = true;
    }
    
    /**
    * @description Constructor
    * @author Kostiantyn Murin | 02-22-2025 
	* @param pStatus result status
    * @param pMessage message about result of action
    * @param pResponseObj object - result of action
    **/
    public Response(String pStatus, String pMessage, Object pResponseObj) {
        this.status = pStatus;
        this.message = pMessage;
        this.responseObj = pResponseObj;
    }
    
    /**
    * @description Constructor
    * @author Kostiantyn Murin | 02-22-2025 
    * @param pStatus result status
    * @param pMessage message about result of action
    **/
    public Response(String pStatus, String pMessage) {
        this.status = pStatus;
        this.message = pMessage;
    }
    
    /**
    * @description Constructor
    * @author Kostiantyn Murin | 02-22-2025 
    * @param isSuccess success flag of operation result
    * @param pResponseObj object - result of action
    **/
    public Response(Boolean isSuccess, Object pResponseObj) {
        this.isSuccess = isSuccess;
        this.responseObj = pResponseObj;
    }
    
    /**
    * @description Constructor
    * @author Kostiantyn Murin | 02-22-2025 
    * @param isSuccess success flag of operation result
    * @param message message about result of action
    **/
    public Response(Boolean isSuccess, String message) {
        this.isSuccess = isSuccess;
        this.message = message;
    }
    
    /**
    * @description Constructor
    * @author Kostiantyn Murin | 02-22-2025 
    * @param pResponseObj object - result of action
    **/
    public Response (Object pResponseObj){
        this.isSuccess = true; 
        this.responseObj = pResponseObj;
    }
    

    /**
    * @description Constructor
    * @author Kostiantyn Murin | 02-22-2025 
    * @param e Exception
    **/
    public Response(Exception e){
        String respMessage = e.getMessage();
        
        if (e instanceof DmlException){
            DmlException dmlEx = (DmlException)e;
            String[] fields = dmlEx.getDmlFieldNames(0);
            respMessage = dmlEx.getDmlMessage(0);
            if (!fields.isEmpty()) {
                respMessage += '\n' + 'Fields:' + String.join(fields, ',');
            }
        }

        this.isSuccess = false; 
        this.responseObj = e.getStackTraceString();
        this.message = respMessage;
    }
}