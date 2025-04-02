# Application Rules and Guidelines

1. **Fix the Application Without System Updates**  
   - Ensure that all fixes are implemented without updating system components.

2. **Flag Location and Retrieval**  
   - Once all issues are resolved, the flag can be found at `/flag`.  
   - The flag will be accessible for a maximum of 10 seconds.

3. **Maintain Application Functionality**  
   - Do not break the main functionalities of the application.  
   - Avoid changing the port used by the application.

4. **Edited Application Behavior**  
   - The edited application will run on `/`.  
   - Exceptions include `/challenge/` and the `/flag` route, which are reserved.  
   - You can interact with your edits through the `/` route.
   - The fix should return message "Don't hack me" with status code 401 when security is breached. 

5. **Application Code**  
   - All code for the running application is located in the preview directory.

Follow these guidelines to ensure a smooth and compliant workflow.