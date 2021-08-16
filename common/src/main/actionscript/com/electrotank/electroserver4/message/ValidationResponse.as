package com.electrotank.electroserver4.message {
    /**
     * This class is used to wrap a true/false validation decsion and store a list of problems if validation failed. When you invoke the validation() method of any message (request, response, event), a ValidationResponse is returned.
     */
    
    public class ValidationResponse {

        private var isValid:Boolean;
        private var problems:Array;
        /**
         * Creates a new instance of the ValiationResponse class. Pass in true/false to specify if the validation succeeded or not, and an array of problems if it failed.
         * @param    True or false. Pass in true if validation succeeded.
         * @param    If validation failed then pass in an array of issues. In this API we use an array of strings.
         */
        public function ValidationResponse(isValid:Boolean, problems:Array) {
            this.isValid = isValid;
            this.problems = problems;
        }
        /**
         * Retunrs an array of strings. 
         * @return An array of strings.
         */
        public function getProblems():Array {
            return problems;
        }
        /**
         * Returns a boolean value specifying if the validation suceeded or failed. If true, it succeeded.
         * @return True or false.
         */
        public function getIsValid():Boolean {
            return isValid;
        }
    }
}
