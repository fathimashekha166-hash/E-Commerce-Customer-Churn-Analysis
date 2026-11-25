USE ecomm;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(WarehouseToHome IS NULL) AS
Missing_WarehouseToHome,
    SUM(HourSpendOnApp IS NULL) AS
Missing_HourSpendOnApp,
    SUM(OrderAmountHikeFromlastYear IS NULL) AS
Missing_OrderAmountHike,
    SUM(DaySinceLastOrder IS NULL) AS
Missing_DaySinceLastOrder,
    SUM(Tenure IS NULL) AS
Missing_Tenure,
	SUM(CouponUsed IS NULL) AS
Missing_CouponUsed,
    SUM(OrderCount IS NULL) AS 
Missing_OrderCount
FROM customer_churn;
    
    SET @avg_warehouse = (SELECT ROUND(AVG(WarehouseToHome))
    FROM customer_churn);
    SET @avg_hours = (SELECT ROUND(AVG(HourSpendOnApp))
    FROM customer_churn);
    SET @avg_hike = (SELECT ROUND(AVG(OrderAmountHikeFromlastYear))
    FROM customer_churn);
    SET @avg_days = (SELECT ROUND(AVG(DaySinceLastOrder))
    FROM customer_churn);
    
    UPDATE customer_churn
    SET WareHouseToHome = @avg_warehouse
    WHERE CustomerID > 0 AND WarehouseToHome IS NULL;
    
    UPDATE customer_churn
    SET HourSpendOnApp = @avg_hours
    WHERE CustomerID > 0 AND HourSpendOnApp IS NULL;
    
    UPDATE customer_churn
    SET OrderAmountHikeFromlastYear = @avg_hike
    WHERE CustomerID > 0 AND OrderAmountHikeFromlastYear IS NULL;
    
    UPDATE customer_churn
    SET DaySinceLastOrder = @avg_days
    WHERE CustomerID > 0 AND DaySinceLastOrder IS NULL;
    
    SET @mode_tenure = (
        SELECT Tenure
        FROM customer_churn
        WHERE Tenure IS NOT NULL
        GROUP BY Tenure
        ORDER BY COUNT(*) DESC
        LIMIT 1
	);
    
    SET @mode_coupon = (
        SELECT CouponUsed
        FROM customer_churn
        WHERE CouponUsed IS NOT NULL
        GROUP BY CouponUsed
        ORDER BY COUNT(*) DESC
        LIMIT 1
	);
    
    SET @mode_order = (
        SELECT OrderCount
        FROM customer_churn
        WHERE OrderCount IS NOT NULL
        GROUP BY OrderCount
        ORDER BY COUNT(*) DESC
        LIMIT 1
	);
    
    UPDATE customer_churn
    SET Tenure = @mode_tenure
    WHERE CustomerID > 0 AND Tenure IS NULL;
    
    UPDATE customer_churn
    SET CouponUsed = @mode_coupon
    WHERE CustomerID > 0 AND CouponUsed IS NULL;
    
    UPDATE customer_churn
    SET OrderCount = @mode_order
    WHERE CustomerID > 0 AND OrderCount IS NULL;
    
    DELETE FROM customer_churn
    WHERE CustomerID > 0 AND 
    WarehouseToHome > 100;
    
    UPDATE customer_churn
    SET PreferredLoginDevice = 'Mobile Phone'
    WHERE CustomerID > 0 AND
    PreferredLoginDevice = 'Phone';
    
    UPDATE customer_churn
    SET PreferedOrderCat = 'Mobile Phone'
    WHERE CustomerID > 0 AND
    PreferedOrderCat = 'Mobile';
    
    UPDATE customer_churn
    SET PreferredPaymentMode = 'Cash on Delivery'
    WHERE CustomerID > 0 AND
    PreferredPaymentMode = 'COD';
    
    UPDATE customer_churn
    SET PreferredPaymentMode = 'Credit Card'
    WHERE CustomerID > 0 AND
    PreferredPaymentMode = 'CC';
    
    ALTER TABLE customer_churn
    RENAME COLUMN PreferedOrderCat TO
    PreferredOrderCat;
    
    ALTER TABLE customer_churn
    RENAME COLUMN HourSpendOnApp TO
    HoursSpendOnApp;
    
    ALTER TABLE customer_churn
    ADD COLUMN ComplaintReceived
    VARCHAR(3),
    ADD COLUMN ChurnStatus VARCHAR(7);
    
    UPDATE customer_churn
    SET ComplaintReceived = CASE
        WHEN Complain = 1 THEN 'Yes'
        ELSE 'No'
	END
    WHERE CustomerID > 0;
    
    UPDATE customer_churn
    SET ChurnStatus = CASE
        WHEN Churn = 1 THEN 'Churned'
        ELSE 'Active'
	END
    WHERE CustomerID > 0;
    
    ALTER TABLE customer_churn
    DROP COLUMN Churn,
    DROP COLUMN Complain;
    
    SELECT
        ChurnStatus,
        COUNT(*) AS Total_Customers
	FROM customer_churn
    GROUP BY ChurnStatus;
    
    SELECT AVG(Tenure) AS
    Average_Tenure
    FROM customer_churn
    WHERE ChurnStatus = 'Churned';
    
    SELECT AVG(CashbackAmount) AS
    Average_Cashback
    FROM customer_churn
    WHERE ChurnStatus = 'Churned';
    
    SELECT
        COUNT(CASE WHEN
	ComplaintReceived = 'Yes' THEN 1 
    END) * 100.0
         / COUNT(*) AS 
	Complaint_Percentage
    FROM customer_churn
    WHERE ChurnStatus = 'Churned';
    
    SELECT CityTier, COUNT(*) AS
    Total_Customers
    FROM customer_churn
    WHERE ChurnStatus = 'Churned'
    AND PreferredOrderCat = 'Laptop & Accessory'
    GROUP BY CityTier
    ORDER BY Total_Customers DESC;
    
    SELECT PreferredPaymentMode,
    COUNT(*) AS Total_Customers
    FROM customer_churn
    WHERE ChurnStatus = 'Active'
    GROUP BY PreferredPaymentMode
    ORDER BY Total_Customers DESC;
    
    SELECT
    SUM(OrderAmountHikeFromlastYear) AS
    Total_Order_Amount_Hike
    FROM customer_churn
    WHERE PreferredLoginDevice IN
    ('Phone', 'Mobile Phone');    
    
    SELECT
    AVG(NumberOfDeviceRegistered) AS
    Average_Registered_Devices
    FROM customer_churn
    WHERE PreferredPaymentMode = 'UPI';
    
    SELECT CityTier, COUNT(*) AS
    Total_Customers
    FROM customer_churn
    GROUP BY CityTier
    ORDER BY Total_Customers DESC;
    
    SELECT Gender, SUM(CouponUsed) AS
    Total_Coupons
    FROM customer_churn
    GROUP BY Gender
    ORDER BY Total_Coupons DESC;
    
    SELECT
         PreferredOrderCat,
         COUNT(*) AS Total_Customers,
         MAX(HoursSpendOnApp) AS
	Maximum_App_Hours
    FROM customer_churn
    Group BY PreferredOrderCat;
    
    DESCRIBE customer_churn;
    
    SELECT
         SUM(OrderCount) AS
	Total_Order_Count,
         MAX(SatisfactionScore) AS
	Maximum_Satisfaction_Score
    FROM customer_churn
    WHERE PreferredPaymentMode = 'Credit Card';
    
    SELECT AVG(SatisfactionScore) AS
    Average_Satisfaction_Score
    FROM customer_churn
    WHERE ComplaintReceived = 'Yes';
    
    SELECT
         PreferredOrderCat,
         COUNT(*) AS Total_Customers
	FROM customer_churn
    WHERE CouponUsed > 5
    GROUP BY PreferredOrderCat;
    
    SELECT
        PreferredOrderCat,
        AVG(CashbackAmount) AS
	Average_Cashback
    FROM customer_churn
    GROUP BY PreferredOrderCat
    ORDER BY Average_Cashback DESC
    LIMIT 3;
    
    SELECT
        PreferredPaymentMode,
        AVG(Tenure) AS Average_Tenure,
        SUM(OrderCount) AS Total_Orders
	FROM customer_churn
    GROUP BY PreferredPaymentMode
    HAVING ROUND(AVG(Tenure), 0) = 10
    AND SUM(OrderCount) > 500;
    
    SELECT
        CASE
            WHEN WarehouseToHome <= 5
	THEN 'Near'
			WHEN WarehouseToHome <= 10
	THEN 'Medium'
            ELSE 'Far'
		END AS Distance_Category,
        ChurnStatus,
        COUNT(*) AS Total_Customers
	FROM customer_churn
    GROUP BY Distance_Category,
    ChurnStatus
    ORDER BY Distance_Category,
    ChurnStatus;
    
    SELECT *
    FROM customer_churn
    WHERE MaritalStatus = 'Married'
       AND CityTier = 1
       AND OrderCount > (SELECT
	AVG(OrderCount) FROM
    customer_churn);
    
    
    CREATE TABLE customer_returns (
        ReturnID INT PRIMARY KEY,
        CustomerID INT,
        ReturnDate Date,
        RefundAmount DECIMAL(10,2)
	);
    
    INSERT INTO customer_returns
    (ReturnID, CustomerID, ReturnDate, RefundAmount)
    VALUES
    (1001,50022,'2023-01-01',2130),
    (1002,50316,'2023-01-23',2000),
    (1003,51099,'2023-02-14',2290),
    (1004,52321,'2023-03-08',2510),
    (1005,52928,'2023-03-20',3000),
    (1006,53749,'2023-04-17',1740),
    (1007,54206,'2023-04-21',3250),
    (1008,54838,'2023-04-30',1990);
    
    SELECT
		r.ReturnID,
        r.CustomerID,
        r.ReturnDate,
        r.RefundAmount,
        c.*
	FROM customer_returns r
    INNER JOIN customer_churn c
       ON r.CustomerID = c.CustomerID
	WHERE c.ChurnStatus = 'Churned'
      AND c.ComplaintReceived = 'Yes';
      
        
            
        
    
        