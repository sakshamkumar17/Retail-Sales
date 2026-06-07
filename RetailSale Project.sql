-- ONLINE RETAIL SALES ANALYSIS
CREATE DATABASE RetailSales;

USE RetailSales;

-- CREATING TABLES
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    registration_date DATE
);

CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    FOREIGN KEY (category_id)
        REFERENCES Categories(category_id)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES Products(product_id)
);

-- ADDING VALUES
INSERT INTO Customers VALUES
(1,'Rahul Kumar','Patna','2024-01-15'),
(2,'Priya Singh','Delhi','2024-02-10'),
(3,'Amit Verma','Mumbai','2024-03-05'),
(4,'Neha Sharma','Bangalore','2024-03-20');

INSERT INTO Categories VALUES
(1,'Electronics'),
(2,'Fashion'),
(3,'Books');

INSERT INTO Products VALUES
(101,'Smartphone',1,25000),
(102,'Laptop',1,60000),
(103,'Jeans',2,1500),
(104,'T-Shirt',2,700),
(105,'SQL Book',3,500);

INSERT INTO Orders VALUES
(1001,1,'2025-01-10'),
(1002,2,'2025-01-12'),
(1003,1,'2025-02-01'),
(1004,3,'2025-02-15'),
(1005,4,'2025-03-01');

INSERT INTO Order_Details VALUES
(1,1001,101,1),
(2,1001,105,2),
(3,1002,103,2),
(4,1003,102,1),
(5,1004,105,3),
(6,1005,104,4),
(7,1005,103,1);

-- TOTAL SALES REVENUE
SELECT SUM(p.price * od.quantity) AS Total_Revenue
FROM Order_Details od
JOIN Products p
ON od.product_id = p.product_id;

-- TOP 3 SELLING PRODUCTS
SELECT p.product_name,
SUM(od.quantity) AS Total_Quantity
FROM Order_Details od
JOIN Products p
ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY Total_Quantity DESC
LIMIT 3;

-- MONTHLY REVENUE REPORT
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS Month,
SUM(p.price * od.quantity) AS Revenue
FROM Orders o
JOIN Order_Details od
ON o.order_id = od.order_id
JOIN Products p
ON od.product_id = p.product_id
GROUP BY Month
ORDER BY Month;

-- CUSTOMER PURCHASE SUMMARY
SELECT c.customer_name,
COUNT(DISTINCT o.order_id) AS Total_Orders,
SUM(p.price * od.quantity) AS Total_Spent
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
JOIN Order_Details od
ON o.order_id = od.order_id
JOIN Products p
ON od.product_id = p.product_id
GROUP BY c.customer_name
ORDER BY Total_Spent DESC;

-- CUSTOMER SPENDING ABOVE AVERAGE
SELECT customer_name, Total_Spent
FROM (
    SELECT c.customer_name,
	SUM(p.price * od.quantity) AS Total_Spent
    FROM Customers c
    JOIN Orders o
    ON c.customer_id = o.customer_id
    JOIN Order_Details od
    ON o.order_id = od.order_id
    JOIN Products p
    ON od.product_id = p.product_id
    GROUP BY c.customer_name
) AS CustomerSummary
WHERE Total_Spent >
(
    SELECT AVG(TotalSpent)
    FROM (
        SELECT SUM(p.price * od.quantity) AS TotalSpent
        FROM Orders o
        JOIN Order_Details od
        ON o.order_id = od.order_id
        JOIN Products p
        ON od.product_id = p.product_id
        GROUP BY o.customer_id
    ) AS AvgTable
);

-- CATEGORY WISE REVENUE
SELECT c.category_name,
SUM(p.price * od.quantity) AS Revenue
FROM Categories c
JOIN Products p
ON c.category_id = p.category_id
JOIN Order_Details od
ON p.product_id = od.product_id
GROUP BY c.category_name
ORDER BY Revenue DESC;

-- RANK PRODUCT BY REVENUE
SELECT product_name,Revenue,
RANK() OVER (ORDER BY Revenue DESC) AS Revenue_Rank
FROM (
    SELECT p.product_name,
	SUM(p.price * od.quantity) AS Revenue
    FROM Products p
    JOIN Order_Details od
    ON p.product_id = od.product_id
    GROUP BY p.product_name
) AS ProductRevenue;

-- CREATING A VIEW
CREATE VIEW Customer_Sales_View AS
SELECT c.customer_name,
COUNT(DISTINCT o.order_id) AS Orders_Count,
SUM(p.price * od.quantity) AS Total_Spent
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
JOIN Order_Details od
ON o.order_id = od.order_id
JOIN Products p
ON od.product_id = p.product_id
GROUP BY c.customer_name;

SELECT * FROM Customer_Sales_View;

