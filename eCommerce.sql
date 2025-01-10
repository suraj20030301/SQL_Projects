CREATE DATABASE Ecommerce;

USE Ecommerce;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(50),
    Email VARCHAR(100),
    Country VARCHAR(50),
    City VARCHAR(50),
    SignUpDate DATE
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50),
    Category VARCHAR(50),
    Price DECIMAL(10, 2)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    Rating INT,
    ReviewDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO Customers VALUES 
(1, 'Alice Green', 'alice@example.com', 'USA', 'New York', '2023-01-10'),
(2, 'Bob Brown', 'bob@example.com', 'Canada', 'Toronto', '2023-02-15'),
(3, 'Charlie Blue', 'charlie@example.com', 'UK', 'London', '2023-03-20'),
(4, 'Daisy White', 'daisy@example.com', 'India', 'Bangalore', '2023-04-10'),
(5, 'Eve Black', 'eve@example.com', 'Australia', 'Sydney', '2023-05-05');

INSERT INTO Products VALUES 
(101, 'Smartphone', 'Electronics', 699.99),
(102, 'Laptop', 'Electronics', 1199.99),
(103, 'T-shirt', 'Apparel', 19.99),
(104, 'Sneakers', 'Footwear', 89.99),
(105, 'Blender', 'Home Appliances', 49.99);

INSERT INTO Orders VALUES 
(201, 1, '2023-01-15', 719.98),
(202, 2, '2023-02-20', 1299.98),
(203, 3, '2023-03-25', 109.98),
(204, 4, '2023-04-15', 69.98),
(205, 5, '2023-05-10', 179.97);

INSERT INTO OrderDetails VALUES 
(301, 201, 101, 1, 699.99),
(302, 201, 103, 1, 19.99),
(303, 202, 102, 1, 1199.99),
(304, 202, 104, 1, 89.99),
(305, 203, 103, 2, 19.99),
(306, 204, 104, 1, 89.99),
(307, 205, 103, 3, 19.99);

INSERT INTO Reviews VALUES 
(401, 1, 101, 5, '2023-01-20'),
(402, 2, 102, 4, '2023-02-25'),
(403, 3, 103, 3, '2023-03-30'),
(404, 4, 104, 4, '2023-04-20'),
(405, 5, 103, 5, '2023-05-15');

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;
SELECT * FROM Reviews;

INSERT INTO Customers VALUES 
(6, 'Ahmed Ali', NULL, 'UAE', 'Dubai', '2023-05-15'),
(7, 'Mei Ling', 'mei.ling@example.com', 'China', 'Beijing', NULL),
(8, 'Michael Johnson', 'michael.j@example.com', NULL, 'New York', '2023-06-10'),
(9, NULL, NULL, 'Canada', 'Toronto', '2023-07-01'),
(10, 'Rajesh Kumar', 'INVALID_EMAIL', 'India', 'Delhi', NULL);

SELECT * FROM Customers;

/* EDA */
/* Handling Missing values in Names */
SELECT * FROM Customers;
SET SQL_SAFE_UPDATES = 0;

UPDATE Customers
SET Name='Unknown'
WHERE Name IS NULL; 

SELECT * FROM Customers;

UPDATE Customers
SET Email ='unknown@example.com'
WHERE Email IS NULL;

SELECT * FROM Customers;

UPDATE Customers
SET Country='NoCountry'
WHERE Country is NULL;

SELECT * FROM Customers;

UPDATE Customers
SET SignUpDate = (
SELECT ROUND(AVG(SignUpDate)) FROM 
(SELECT SignUpDate FROM Customers WHERE SignUpDate IS NOT NULL) AS temp
)
WHERE SignUpDate IS NULL;

SELECT * FROM Customers;

/* Top-Selling products :- Which Product generate the highest revenue */
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;

WITH CTE1 AS(
SELECT ProductID,
Quantity*UnitPrice AS Total
FROM OrderDetails
),
CTE2 AS(
SELECT ProductID, SUM(Total) AS Total
FROM CTE1 GROUP BY ProductID
)
SELECT p.ProductID,p.ProductName, 
c.Total AS HightestRevenue
FROM Products p LEFT JOIN CTE2 c ON p.ProductID=c.ProductID
ORDER BY c.Total DESC LIMIT 1;

/* Customer Analysis:- Who are the most frequent or valuable customers? */ 
SELECT * FROM Orders;
SELECT * FROM OrderDetails;

WITH CTE1 AS(
SELECT OrderID,
COUNT(OrderID) AS CountOfOrder,
SUM(Quantity*UnitPrice) as Spend
FROM OrderDetails
GROUP BY OrderID
)
SELECT 
o.CustomerID,
cu.Name,
SUM(c.CountOfOrder) OVER( PARTITION BY o.CustomerID) AS Frequency,
c.Spend
FROM Orders o LEFT JOIN CTE1 c
ON o.OrderID=c.OrderID LEFT JOIN Customers cu 
ON cu.CustomerID=o.CustomerID
ORDER BY c.Spend DESC
LIMIT 1;


/* Sales trends:- Analyze Monthly and Yearly sales performance */

WITH CTE1 AS(
SELECT
od.ProductID,
od.Quantity,
MONTHNAME(o.OrderDate) AS MonthName,
o.OrderDate
FROM OrderDetails od LEFT JOIN Orders o
ON od.OrderID=o.OrderID
)

SELECT ProductID,
SUM(CASE WHEN MonthName='January' THEN Quantity ELSE 0 END) AS January,
SUM(CASE WHEN MonthName='February' THEN Quantity ELSE 0 END) AS February,
SUM(CASE WHEN MonthName='March' THEN Quantity ELSE 0 END) AS March,
SUM(CASE WHEN MonthName='April' THEN Quantity ELSE 0 END) AS April,
SUM(CASE WHEN MonthName='May' THEN Quantity ELSE 0 END) AS May,
SUM(CASE WHEN MonthName='June' THEN Quantity ELSE 0 END) AS June,
SUM(CASE WHEN MonthName='July' THEN Quantity ELSE 0 END) AS July,
SUM(CASE WHEN MonthName='August' THEN Quantity ELSE 0 END) AS August,
SUM(CASE WHEN MonthName='September' THEN Quantity ELSE 0 END) AS September,
SUM(CASE WHEN MonthName='October' THEN Quantity ELSE 0 END) AS October,
SUM(CASE WHEN MonthName='November' THEN Quantity ELSE 0 END) AS November,
SUM(CASE WHEN MonthName='December' THEN Quantity ELSE 0 END) AS December,
SUM(Quantity) AS Yearly
FROM CTE1
GROUP BY ProductID
ORDER BY SUM(Quantity) DESC;

/* Category Performance :- Which product categories perform the best ? */
SELECT * FROM Products;

WITH CTE1 AS(
SELECT
od.ProductID,
od.Quantity,
MONTHNAME(o.OrderDate) AS MonthName,
o.OrderDate
FROM OrderDetails od LEFT JOIN Orders o
ON od.OrderID=o.OrderID
)
SELECT c.ProductID, p.ProductName, p.Category,
SUM(c.Quantity) AS YearlySale
FROM CTE1 c LEFT JOIN Products p
ON c.ProductID=p.ProductID
GROUP BY c.ProductID
ORDER BY SUM(c.Quantity) DESC
LIMIT 1;

/* Geographical Insights :- Which regions/cities have the highest sales */

SELECT o.CustomerID,
COUNT(od.Quantity) AS ProductSale,
c.Country,
c.City
FROM OrderDetails od LEFT JOIN Orders o 
ON od.OrderID=o.OrderID 
INNER JOIN Customers c 
ON o.CustomerID=c.CustomerID
GROUP BY o.CustomerID;

/* Revenue by Month */

SELECT
MONTH(OrderDate) AS Month,
SUM(TotalAmount) AS Revenue
FROM Orders
GROUP BY MONTH(OrderDate)
ORDER BY Month;

/* Top 5 Products by Revenue */
SELECT
p.ProductName,
SUM(od.Quantity*od.UnitPrice) AS TotalRevenue
FROM OrderDetails od LEFT JOIN Products p
ON od.ProductID=p.ProductID
GROUP BY p.ProductName
ORDER BY TotalRevenue DESC
LIMIT 5;

/* Average Customer Spend */
SELECT
c.Name,
AVG(o.TotalAmount) as AVGSpend
FROM Customers c JOIN Orders o
ON c.CustomerID=o.CustomerID
GROUP BY c.Name
ORDER BY AVGSpend DESC;

/* Most Active Customers */
WITH CTE1 AS(
SELECT OrderID,
COUNT(OrderID) AS CountOfOrder,
SUM(Quantity*UnitPrice) as Spend
FROM OrderDetails
GROUP BY OrderID
)
SELECT 
o.CustomerID,
cu.Name,
SUM(c.CountOfOrder) OVER( PARTITION BY o.CustomerID) AS Frequency,
c.Spend
FROM Orders o LEFT JOIN CTE1 c
ON o.OrderID=c.OrderID LEFT JOIN Customers cu 
ON cu.CustomerID=o.CustomerID
ORDER BY c.Spend DESC
LIMIT 5;

/* Product Rating Analysis:- Correlate product sales with average ratings */
SELECT * FROM Reviews;

WITH CTE1 AS(
SELECT 
o.ProductID,
SUM(o.Quantity) as TotalSale,
ROUND(AVG(r.Rating)) as AVGRate
FROM OrderDetails o JOIN Reviews r
ON o.ProductID=r.ProductID
GROUP BY o.ProductID
),
CTE2 AS(
SELECT 
ProductID,  
TotalSale - (SELECT ROUND(AVG(TotalSale)) FROM CTE1) AS X,  
AVGRate - (SELECT ROUND(AVG(AVGRate)) FROM CTE1) AS Y  
FROM 
CTE1
),
CTE3 AS(
SELECT 
SUM(X*Y)/COUNT(*) AS Covariance,
POWER(SUM(X*X)/COUNT(*),0.5) AS SDX,
POWER(SUM(Y*Y)/COUNT(*),0.5) AS SDY
FROM CTE2
)
SELECT 
ROUND(Covariance/(SDX*SDY),2) AS CorRelation 
FROM CTE3;

/* Customer Retention:- Analyze repeat customer trends DATADIFF or similar date features  */
SELECT 
o.CustomerID,
COUNT(od.OrderID) AS TotalOrders,
MIN(o.OrderDate) AS FirstPurchaseDate,
MAX(o.OrderDate) AS LastPurchaseDate,
DATEDIFF(MAX(o.OrderDate), MIN(o.OrderDate)) AS RetentionPeriod,
CASE WHEN COUNT(od.OrderID) = 1 THEN 'One-Time Buyer' 
ELSE 'Long-Term Retention'
END AS CustomerCategory
FROM Orders o JOIN OrderDetails od
ON o.OrderID=od.OrderID
GROUP BY o.CustomerID;
