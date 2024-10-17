CREATE DATABASE crm_db;
USE crm_db;
-- Customer Table
CREATE TABLE Customer (
customer_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    address VARCHAR(255),
    registration_date DATE
);
-- Lead Table
CREATE TABLE LeadInfo (
lead_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    status VARCHAR(50),
    created_at DATE,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
    );
-- Contact Table
CREATE TABLE Contact (
    contact_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    role VARCHAR(50),
    customer_id INT,
    lead_id INT,
     FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
      FOREIGN KEY (lead_id) REFERENCES LeadInfo(lead_id)
      );
 -- Opportunity Table
 CREATE TABLE Opportunity (
 opportunity_id INT PRIMARY KEY AUTO_INCREMENT,
    description TEXT,
    value DECIMAL(10, 2),
    status VARCHAR(50),
    close_date DATE,
    customer_id INT,
    lead_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (lead_id) REFERENCES LeadInfo(lead_id)
);
 -- Insert some customers
INSERT INTO Customer (name, email, phone, address, registration_date)
VALUES ('John Doe', 'john@example.com', '123456789', '123 Main St', '2024-10-12'),
('Jane Doe', 'jane@example.com', '223456789', '133 Main St', '2024-10-11'),
('Jeremy', 'jeremy@example.com', '323456789', '143 Main St', '2024-10-10'),
('Remy', 'remy@example.com', '423456789', '153 Main St', '2024-10-09');

-- Insert some leads
INSERT INTO LeadInfo (name, email, phone, status, created_at)
VALUES ('Jane Smith', 'jane@lead.com', '987654321', 'New', '2024-10-11'),
('J Smith', 'j@lead.com', '997754321', 'Open', '2024-10-12'),
('T Rex', 't@lead.com', '987754322', 'Open', '2024-10-13'),
('Yen', 'y@lead.com', '987774321', 'Open', '2024-10-14');

-- Insert contacts for the customer
INSERT INTO Contact (first_name, last_name, email, phone, role, customer_id)
VALUES ('Mark', 'Doe', 'mark.doe@example.com', '321654987', 'Decision Maker', 1),
('Stephen', 'King', 's.k@example.com', '322654987', 'Influencer', 2),
('Fang', 'Shu', 'f.s@example.com', '322654988', 'Manager', 3),
('Pen', 'Shil', 'p.s@example.com', '322654987', 'Advisor', 4);

-- Insert opportunities
INSERT INTO Opportunity (description, value, status, close_date, customer_id)
VALUES ('New software implementation', 10000.00, 'Open', '2024-12-01', 1),
('RFID Products', 10000.00, 'Won', '2024-12-02', 2),
('Solar Panel', 10000.00, 'Lost', '2024-12-03', 3),
('RFID', 1000.00, 'Open', '2024-12-04', 4);

-- List all customers:
  SELECT * FROM Customer;

-- Find all leads that are 'New':
SELECT * FROM LeadInfo WHERE status ='New';

-- Get opportunities for a specific customer:
SELECT * FROM Opportunity where customer_id=1;

DELETE FROM Opportunity
WHERE opportunity_id=5;

-- Get contacts for a specific customer:
SELECT * FROM Contact where customer_id=4;

ALTER TABLE Customer 
ADD COLUMN status VARCHAR(50) DEFAULT 'Active';

ALTER TABLE LeadInfo
ADD COLUMN conversion_status VARCHAR(50) DEFAULT 'New';  -- Could be 'New', 'Contacted', 'Qualified', 'Converted'
SELECT * FROM LeadInfo;

-- TRIGGER
-- The trigger will automatically update the customer's status to "Converted" when the lead's status changes to "Converted."

DELIMITER //
-- Added DELIMITER statements to change the delimiter temporarily. This allows the use of semicolons within the trigger definition.

CREATE TRIGGER auto_lead_update 
AFTER UPDATE ON LeadInfo
FOR EACH ROW
BEGIN
    -- Check if the status changed to 'Contacted'
    IF NEW.status = 'Contacted' THEN
        -- Update corresponding conversion_status
        UPDATE LeadInfo
        SET conversion_status = 'Qualified' 
        WHERE lead_id = NEW.lead_id;
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS auto_lead_update;
DESCRIBE LeadInfo;

INSERT INTO LeadInfo (name, email, phone, status, conversion_status, created_at)
VALUES ('Stupid Hoe', 'hoe.doe@example.com', '123-456-7890', 'New', 'New', '2024-10-12');

SELECT * FROM LeadInfo;

-- Update the lead's status to 'Contacted' to trigger the update
UPDATE LeadInfo
SET status = 'Contacted'
WHERE lead_id = 6;

SET GLOBAL log_bin_trust_function_creators = 1;
SET GLOBAL log_bin_trust_function_creators = 0;
SHOW VARIABLES LIKE 'log_bin_trust_function_creators';

-- Check if the conversion_status has changed to 'Qualified'
SELECT * FROM LeadInfo WHERE lead_id = 1;


-- Just modify new values
DELIMITER //

CREATE TRIGGER auto_update_lead_status
BEFORE UPDATE ON LeadInfo
FOR EACH ROW
BEGIN
    -- Directly update the NEW values, no need to run another UPDATE statement
    IF NEW.status = 'Contacted' THEN
	   SET NEW.conversion_status = 'Qualified';
    END IF;
END//

DELIMITER ;

DROP TRIGGER IF EXISTS auto_update_lead_status;
-- WTF?
DELIMITER //

CREATE TRIGGER auto_update_lead_status 
BEFORE UPDATE ON LeadInfo
FOR EACH ROW
BEGIN
    -- Directly update the NEW values, no need to run another UPDATE statement
    IF NEW.status = 'Contacted' THEN
        SET NEW.conversion_status = 'Qualified';
    END IF;
END //

DELIMITER ;

UPDATE LeadInfo
SET status='Contacted'
WHERE lead_id = 4;

-- Trying out Stored Procedure insted of triggers beacuse triggers completely fucked up my brain
DELIMITER $$

CREATE PROCEDURE update_lead_status(
    IN p_lead_id INT,
    IN p_status VARCHAR(50)
)
BEGIN
    -- Update both status and conversion_status
    UPDATE LeadInfo
    SET status = p_status,
        conversion_status = CASE 
                               WHEN p_status = 'Contacted' THEN 'Qualified'
                               ELSE conversion_status
                            END
    WHERE lead_id = p_lead_id;
END $$

DELIMITER ;
-- Now calling stored procedure ... i'm shit scared
CALL update_lead_status(4, 'Contacted');

-- Same mfking issue so I'm checking all triggers and dropping them
SHOW TRIGGERS LIKE 'LeadInfo';
DROP TRIGGER IF EXISTS update_customer_status_on_conversion;
DROP TRIGGER IF EXISTS auto_lead_update;

-- I also gotta drop my stored procedure and redo it again
DROP PROCEDURE IF EXISTS update_lead_status;

DELIMITER $$

CREATE PROCEDURE update_lead_status(
    IN p_lead_id INT,
    IN p_status VARCHAR(50)
)
BEGIN
    -- Safely update both status and conversion_status
    UPDATE LeadInfo
    SET status = p_status,
        conversion_status = CASE 
                               WHEN p_status = 'Contacted' THEN 'Qualified'
                               ELSE conversion_status
                            END
    WHERE lead_id = p_lead_id;
END $$

DELIMITER ;

-- trying to call the stored procedure, fingers crossed
CALL update_lead_status(4, 'Contacted');
-- HURAYYYYYYYYYYYYYY

SELECT * from LeadInfo;