# CRM
Customer Relationship Management (CRM) system using SQL
## Key Entities:
*Customer*: Individuals or companies purchasing or using your services.

*Lead*: Potential customers who have shown interest in your product/service but haven't yet made a purchase.

*Contact*: Individuals related to either customers or leads. This can be multiple contacts per customer or lead.

*Opportunity*: Sales opportunities, linked to a lead or customer, representing potential revenue.

I have used Trigger and Stored Procedure in this project

## Trigger:
-- The trigger automatically updates the customer's status to "Converted" when the lead's status changes to "Converted."
CREATE TRIGGER update_customer_status_on_conversion
AFTER UPDATE ON LeadInfo
FOR EACH ROW
BEGIN
    -- Check if the conversion_status column in LeadInfo is changed to 'Converted'
    IF NEW.conversion_status = 'Converted' THEN
        -- Update the corresponding customer's status
        UPDATE Customer
        SET status = 'Converted'
        WHERE customer_id = NEW.customer_id;
    END IF;
END;
# Explanation:
Trigger Name: update_customer_status_on_conversion
Event: AFTER UPDATE ON LeadInfo means the trigger will fire after an UPDATE operation on the LeadInfo table.
Condition: It checks if the conversion_status column is set to 'Converted'.
Action: If the condition is true, it updates the corresponding Customer record's status to 'Converted'.
# Testing the trigger
UPDATE LeadInfo
SET conversion_status = 'Converted'
WHERE lead_id = 1;

-- Check the customer's status
SELECT * FROM Customer WHERE customer_id = 1;

## Stored Procedure
-- Using Stored Procedure to update fields in the same table 
DELIMITER $$

CREATE PROCEDURE update_lead_status(
    IN p_lead_id INT,
    IN p_status VARCHAR(50)
)
BEGIN
    -- update both status and conversion_status
    UPDATE LeadInfo
    SET status = p_status,
        conversion_status = CASE 
                               WHEN p_status = 'Contacted' THEN 'Qualified'
                               ELSE conversion_status
                            END
    WHERE lead_id = p_lead_id;
END $$
DELIMITER ;
# Explanation
conversion_status = CASE:
This part starts a CASE statement, which is used for conditional logic inside SQL queries. It allows us to set conversion_status based on the value of p_status.

WHEN p_status = 'Contacted' THEN 'Qualified':
Here, the CASE checks if the value of the input parameter p_status (passed when the stored procedure is called) is equal to 'Contacted'.

If p_status is 'Contacted': Then, the conversion_status column will be updated to 'Qualified'.
ELSE conversion_status:
This is the fallback for the CASE statement.

If p_status is anything other than 'Contacted', the conversion_status will remain unchanged (i.e., it will retain its current value). The ELSE clause says to keep conversion_status as it is.
END:
This closes the CASE statement.

WHERE lead_id = p_lead_id;:
This part of the code specifies which record(s) in the LeadInfo table to update.

The update will only be applied to the row where lead_id equals p_lead_id, which is the ID passed as an input parameter when calling the stored procedure.

# Call Stored Procedure
CALL update_lead_status(4, 'Contacted');
-- Explanation:
p_lead_id = 4: So, we are targeting the row in LeadInfo where lead_id = 4.
p_status = 'Contacted': Since p_status is 'Contacted', the CASE statement will trigger the THEN clause, updating conversion_status to 'Qualified'.
# Summary
The CASE statement allows you to conditionally update conversion_status.
If p_status is 'Contacted', the conversion_status is set to 'Qualified'.
For any other p_status, conversion_status stays as it is.
The update only applies to the row where lead_id matches p_lead_id.
