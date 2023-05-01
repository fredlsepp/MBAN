USE `H_Accounting`;

#  First create a view with the merged general table
DROP VIEW IF EXISTS `fboelck_view`;   
CREATE VIEW `fboelck_view` AS
SELECT 
	`jei`.`entry_date`,
	`jeli`.`company_id`,
    `jei`.`journal_entry_id`,
    `jeli`.`line_item`,
    `ac`.`account_id`,
    `ac`.`account_code`,
    `ac`.`account`,
    `ac`.`inventory_type`,
    `ac`.`bank_account_type`,
    `ac`.`balance_sheet_section_id`,
	`ac`.`profit_loss_section_id`,
	`ss`.`statement_section_order`,
    `ss`.`statement_section_code`,
    `ss`.`statement_section`,
    `ac`.`fiscal_id`,
    `jeli`.`description`,
    `jei`.`journal_entry`,
    `ss`.`debit_is_positive`,
	`jeli`.`debit`,
    `jeli`.`credit`,
    `jei`.`debit_credit_balanced`,
    `jei`.`cancelled`
	FROM `H_Accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `H_Accounting`.`account` AS `ac` ON `ac`.`account_id` = `jeli`.`account_id`
	INNER JOIN `H_Accounting`.`journal_entry` AS `jei` ON `jei`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `H_Accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `ac`.`profit_loss_section_id`
    WHERE `jeli`.`company_id` = 1
    AND `jei`.`closing_type` <> 1
;

-- A stored procedure, or a stored routine, is like a function in other programming languages
-- We write the code once, and the code can then be reused over and over again
-- We can pass on arguments into the stored procedure. 
-- i.e. we can give a specific input to a store procedure
-- For example we could determine the specific for which we want to produce the profit and loss statement (year)

-- Before wrting a stored procedure we have to change the DELIMTER (;)
-- This has to be done, so the compiler of SQL will know when we are closing the stored procedure and when we are
-- closing the specific Select command

DROP PROCEDURE IF EXISTS `H_Accounting`.`sp_profitloss_fboelck`;
-- The tpycal delimiter for Stored procedures is a double dollar sign
DELIMITER $$

CREATE PROCEDURE `H_Accounting`.`sp_profitloss_fboelck`(varCalendarYear SMALLINT)
BEGIN
	-- We receive as an argument the year for which we will calculate the revenues
    -- This value is stored as an 'YEAR' type in the variable `varCalendarYear`
    -- To avoid confusion among which are fields from a table vs. which are the variables
    -- A good practice is to adopt a naming convention for all variables
    -- In these lines of code we are naming prefixing every variable as "var"
  
	-- DECLARING THE VARIABLES FOR THE PROFIT & LOSS STATEMENT
	-- We can define variables inside of our procedure
    
    -- Defining the variable for Revenue & Revenue0
	DECLARE varTotalRevenue DOUBLE DEFAULT 0;
    DECLARE varTotalRevenue0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalRRD & TotalRRD0
    DECLARE varTotalRRD DOUBLE DEFAULT 0;
    DECLARE varTotalRRD0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalCostsGS & TotalCostsGS0
    DECLARE varTotalCostsGS DOUBLE DEFAULT 0;
    DECLARE varTotalCostsGS0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalAdminExp  & TotalAdminExp0
    DECLARE varTotalAdminExp DOUBLE DEFAULT 0;
    DECLARE varTotalAdminExp0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalSellExp & TotalSellExp0
    DECLARE varTotalSellExp DOUBLE DEFAULT 0;
    DECLARE varTotalSellExp0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalOtExp & TotalOtExp0
    DECLARE varTotalOtExp DOUBLE DEFAULT 0;
    DECLARE varTotalOtExp0 DOUBLE DEFAULT 0;
    
	-- Defining the variable for TotalOtInc & TotalOtInc0
    DECLARE varTotalOtInc DOUBLE DEFAULT 0;
    DECLARE varTotalOtInc0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalIncTax & TotalIncTax0
    DECLARE varTotalIncTax DOUBLE DEFAULT 0; 
    DECLARE varTotalIncTax0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalOtTax & TotalOtTax0
	DECLARE varTotalOtTax DOUBLE DEFAULT 0;
    DECLARE varTotalOtTax0 DOUBLE DEFAULT 0;
    
	-- Defining variable Depreciations
    DECLARE Depreciations DOUBLE DEFAULT 0;
    DECLARE Depreciations_1 DOUBLE DEFAULT 0;

	-- Defining variable AccountsReceivable
    DECLARE AccountsReceivable DOUBLE DEFAULT 0;
    DECLARE AccountsReceivable_1 DOUBLE DEFAULT 0;

	-- Defining variable Depreciations
    DECLARE AccountsPayable DOUBLE DEFAULT 0;
    DECLARE AccountsPayable_1 DOUBLE DEFAULT 0;

	-- Defining variable AccountsReceivable
    DECLARE TaxesPayable DOUBLE DEFAULT 0;
    DECLARE TaxesPayable_1 DOUBLE DEFAULT 0;
    
	-- Defining variable AccountsReceivable
    DECLARE Equipment DOUBLE DEFAULT 0;
    DECLARE Equipment_1 DOUBLE DEFAULT 0;
    
	-- Defining variable AccountsReceivable
    DECLARE FGains DOUBLE DEFAULT 0;
    DECLARE FGains_1 DOUBLE DEFAULT 0;
    
	-- Defining variable AccountsReceivable
    DECLARE FExpenses DOUBLE DEFAULT 0;
    DECLARE FExpenses_1 DOUBLE DEFAULT 0;

    -- Calculating the revenue for the actual and previous year and store it into the declared variables
	SELECT SUM(COALESCE(credit,0) - COALESCE(debit,0)) INTO varTotalRevenue
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 68
        AND YEAR(entry_date) = varCalendarYear
	;

	SELECT SUM(COALESCE(credit,0) - COALESCE(debit,0)) INTO varTotalRevenue0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 68
        AND YEAR(entry_date) = varCalendarYear - 1
	;

    -- Calculating the total returns, refunds & discounts for the actual and previous year and store them into the declared variables
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalRRD
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 69
        AND YEAR(entry_date) = varCalendarYear
	;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalRRD0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 69
        AND YEAR(entry_date) = varCalendarYear - 1
	;
    
    -- Calculating the total of goods & services  for the actual and previous year and store them into the declared variables
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalCostsGS
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 74
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalCostsGS0 
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 74
        AND YEAR(entry_date) = varCalendarYear - 1
        ;        
        
    -- Calculating the administrative expenses for the actual and previous year and store it into the declared variables
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalAdminExp
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 75
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalAdminExp0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 75
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
    
    -- Calculating the selling expenses for the actual and previous year and store it into the declared variables
	SELECT 
    SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalSellExp
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 76
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT 
    SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalSellExp0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 76
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
    
    -- Calculating the total other expenses for the actual and previous year and store it into the declared variables
	SELECT 
    SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalOtExp
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 77
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT 
    SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalOtExp0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 77
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
        
	-- Calculating the total other income taxes for the actual and previous year and store it into the declared variables
	SELECT 
    SUM(COALESCE(credit,0) - COALESCE(debit,0)) INTO varTotalOtInc
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 78
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT 
    SUM(COALESCE(credit,0) - COALESCE(debit,0)) INTO varTotalOtInc0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 78
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
        
	--  We calculate the value of the income taxes for the given year and we store it into the variable we just declared
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalIncTax
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 79
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalIncTax0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 79
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
        
	--  We calculate the value of the other taxes for the given year and we store it into the variable we just declared
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalOtTax
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 80
        AND YEAR(entry_date) = varCalendarYear
        ;
        
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalOtTax0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 80
        AND YEAR(entry_date) = varCalendarYear - 1
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO Depreciations
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '171%' OR account_code LIKE '504%'
        AND YEAR(entry_date) = varCalendarYear 
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO Depreciations_1
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '171%' OR account_code LIKE '504%'
        AND YEAR(entry_date) = varCalendarYear - 1
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO AccountsReceivable
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '105%' OR account_code LIKE '107%'
        AND YEAR(entry_date) = varCalendarYear 
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO AccountsReceivable_1
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '105%' OR account_code LIKE '107%'
        AND YEAR(entry_date) = varCalendarYear - 1
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO AccountsPayable
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '120%' OR account_code LIKE '501%' OR account_code LIKE '201%' OR account_code LIKE '601%' OR account_code LIKE '205%'
        AND YEAR(entry_date) = varCalendarYear 
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO AccountsPayable_1
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '120%' OR account_code LIKE '501%' OR account_code LIKE '201%' OR account_code LIKE '601%' OR account_code LIKE '205%'
        AND YEAR(entry_date) = varCalendarYear - 1
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO TaxesPayable
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '611%' 
        AND YEAR(entry_date) = varCalendarYear 
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO TaxesPayable_1
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '611%'
        AND YEAR(entry_date) = varCalendarYear - 1
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO Equipment
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '155%' OR account_code LIKE '154%' OR account_code LIKE '156%' 
        AND YEAR(entry_date) = varCalendarYear 
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO Equipment_1
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '155%' OR account_code LIKE '154%' OR account_code LIKE '156%' 
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
	
    SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO FGains
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '701%' 
        AND YEAR(entry_date) = varCalendarYear 
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO FGains_1
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '701%' 
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
	
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO FExpenses
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '702%' 
        AND YEAR(entry_date) = varCalendarYear 
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO FExpenses_1
		FROM H_Accounting.fboelck_view
		WHERE account_code LIKE '702%' 
        AND YEAR(entry_date) = varCalendarYear - 1
        ;

    -- Let's drop the `tmp` table where we will input the revenue
	-- The IF EXISTS is important. Because if the table does not exist the DROP alone would fail
	-- A store procedure will stop running whenever it faces an error. 
	DROP TABLE IF EXISTS `H_Accounting`.`fboelck_tmp`;
  
	-- Now we are certain that the table does not exist, we create with the columns that we need
	CREATE TABLE `H_Accounting`.`fboelck_tmp` (
    profit_loss_line_number INT,
    label VARCHAR(50),
    current_amount VARCHAR(50),
    previous_year_amount VARCHAR(50)
);
  
  -- INSERTING THE ROWS FOR THE PROFIT AND LOSS STATEMENT
	-- Now we insert the a header for the report
	INSERT INTO `H_Accounting`.`fboelck_tmp` 
		   (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES (1, 'CASH FLOW STATEMENT', "In '000s of USD", "In '000s of USD");
  
	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(2, '', '', '');

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(3, 'OPERATIONS', '', '');

	-- Next We insert the Net Profit (Profit Before Tax - Total Income Taxes + Total Other Taxes 
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(4, 'Net Earnings', format((COALESCE(varTotalRevenue, 0) - COALESCE(varTotalRRD, 0) - COALESCE(varTotalCostsGS, 0) - COALESCE(varTotalAdminExp, 0)  - COALESCE(varTotalSellExp, 0)  - COALESCE(varTotalOtExp, 0)  + COALESCE(varTotalOtInc, 0) - COALESCE(varTotalIncTax, 0) - COALESCE(varTotalOtTax, 0)) / 1000, 2),
                                format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0) - COALESCE(varTotalCostsGS0, 0) - COALESCE(varTotalAdminExp0, 0)  - COALESCE(varTotalSellExp0, 0)  - COALESCE(varTotalOtExp0, 0)  + COALESCE(varTotalOtInc0, 0) - COALESCE(varTotalIncTax0, 0) - COALESCE(varTotalOtTax0, 0)) / 1000, 2));																							
	
	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(5, '', '', '');

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(6, 'Additions to Cash', '', '');
    
	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(7, 'Depreciations', COALESCE(format(Depreciations / 1000, 2),0), COALESCE(format(Depreciations_1 / 1000, 2),0));
	
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(8, 'Decrease in Accounts Receivable', COALESCE(format(AccountsReceivable / 1000, 2),0), COALESCE(format(AccountsReceivable_1 / 1000, 2),0));

    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(9, 'Increase in Accounts Payable', COALESCE(format(AccountsPayable / 1000, 2),0), COALESCE(format(AccountsPayable_1 / 1000, 2),0));

    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(10, 'Increase in Taxes Receivable', COALESCE(format(TaxesPayable / 1000, 2),0), COALESCE(format(TaxesPayable_1 / 1000, 2),0));

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(11, '', '', '');

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(12, 'Substractions from Cash', '', '');

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(13, 'Increase in Inventory', 0, 0);

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(14, '', '', '');

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(15, 'Net Cash from Operations', format((COALESCE(varTotalRevenue, 0) - COALESCE(varTotalRRD, 0) - COALESCE(varTotalCostsGS, 0) - COALESCE(varTotalAdminExp, 0)  - COALESCE(varTotalSellExp, 0)  - COALESCE(varTotalOtExp, 0)  + COALESCE(varTotalOtInc, 0) - COALESCE(varTotalIncTax, 0) - COALESCE(varTotalOtTax, 0) + COALESCE(Depreciations_1, 0) + COALESCE(AccountsReceivable_1, 0) + COALESCE(AccountsPayable_1, 0) + COALESCE(TaxesPayable_1, 0)) / 1000, 2),
											 format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0) - COALESCE(varTotalCostsGS0, 0) - COALESCE(varTotalAdminExp0, 0)  - COALESCE(varTotalSellExp0, 0)  - COALESCE(varTotalOtExp0, 0)  + COALESCE(varTotalOtInc0, 0) - COALESCE(varTotalIncTax0, 0) - COALESCE(varTotalOtTax0, 0) + COALESCE(Depreciations, 0) + COALESCE(AccountsReceivable, 0) + COALESCE(AccountsPayable, 0) + COALESCE(TaxesPayable, 0) ) / 1000, 2));
                                             			

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(16, '', '', '');

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(17, 'INVESTING', '', '');

    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(18, 'Equipment', COALESCE(format(Equipment / 1000, 2),0), COALESCE(format(Equipment_1 / 1000, 2),0));

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(19, '', '', '');

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(20, 'FINANCING', '', '');

    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(21, 'Financial Gains', COALESCE(format(FGains / 1000, 2),0), COALESCE(format(FGains_1 / 1000, 2),0));

    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(22, 'Financial Expenses', COALESCE(format(FExpenses / 1000, 2),0), COALESCE(format(FExpenses_1 / 1000, 2),0));

	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(23, '', '', '');
    
 	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, current_amount, previous_year_amount)
	VALUES 	(24, 'Cash Flow Final Result', format((COALESCE(varTotalRevenue, 0) - COALESCE(varTotalRRD, 0) - COALESCE(varTotalCostsGS, 0) - COALESCE(varTotalAdminExp, 0)  - COALESCE(varTotalSellExp, 0)  - COALESCE(varTotalOtExp, 0)  + COALESCE(varTotalOtInc, 0) - COALESCE(varTotalIncTax, 0) - COALESCE(varTotalOtTax, 0) + COALESCE(Depreciations, 0) + COALESCE(AccountsReceivable, 0) + COALESCE(AccountsPayable, 0) + COALESCE(TaxesPayable, 0) - COALESCE(Equipment, 0) - COALESCE(FExpenses, 0) + COALESCE(FGains, 0)) / 1000, 2), 
                                           format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0) - COALESCE(varTotalCostsGS0, 0) - COALESCE(varTotalAdminExp0, 0)  - COALESCE(varTotalSellExp0, 0)  - COALESCE(varTotalOtExp0, 0)  + COALESCE(varTotalOtInc0, 0) - COALESCE(varTotalIncTax0, 0) - COALESCE(varTotalOtTax0, 0) + COALESCE(Depreciations_1, 0) + COALESCE(AccountsReceivable_1, 0) + COALESCE(AccountsPayable_1, 0) + COALESCE(TaxesPayable_1, 0) - COALESCE(Equipment_1, 0) - COALESCE(FExpenses_1, 0) + COALESCE(FGains_1, 0)) / 1000, 2));
   
    
END $$
DELIMITER ;
-- The line above changes the DELiMITER back to the original semicolon 

CALL `H_Accounting`.`sp_profitloss_fboelck` (2016);

SELECT * FROM `H_Accounting`.`fboelck_tmp`;