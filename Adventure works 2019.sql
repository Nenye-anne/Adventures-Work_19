SELECT*
FROM AdventureWorks2019;


---(1) what are the orders above average total

SELECT SalesOrderID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > (
    SELECT AVG(TotalDue) FROM Sales.SalesOrderHeader
);

----(2) Total sales by territory

SELECT 
    st.Name AS Territory,
    (
        SELECT SUM(TotalDue)
        FROM Sales.SalesOrderHeader
        WHERE TerritoryID = st.TerritoryID
    ) AS TotalSales
FROM Sales.SalesTerritory st;

--- (3)Products that has never been sold

SELECT p.Name
FROM Production.Product p
WHERE p.ProductID NOT IN (
    SELECT DISTINCT ProductID 
    FROM Sales.SalesOrderDetail
);

---(4) Top 5 customers by total purchase amount

SELECT TOP 5 c.CustomerID, p.FirstName, p.LastName, SUM(soh.TotalDue) AS TotalSpent
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalSpent DESC;

--- (5) Salespersons with total sales > $500,000

SELECT s.BusinessEntityID, p.FirstName, p.LastName, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesPerson s
JOIN Person.Person p ON s.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON s.BusinessEntityID = soh.SalesPersonID
GROUP BY s.BusinessEntityID, p.FirstName, p.LastName
HAVING SUM(soh.TotalDue) > 500000;

---(6) Vendors that supply more than 3 products

SELECT v.Name, COUNT(DISTINCT p.ProductID) AS ProductCount
FROM Purchasing.ProductVendor pv
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
JOIN Production.Product p ON pv.ProductID = p.ProductID
GROUP BY v.Name
HAVING COUNT(DISTINCT p.ProductID) > 3;

---(7) Most expensive product per category

SELECT pc.Name AS Category, MAX(p.ListPrice) AS MaxPrice
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name;

---(8) Highest selling product by revenue

SELECT TOP 1 p.Name, SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;

---(9)What is Total Revenue,Total Cost, Total profit

SELECT 
    SUM(sod.LineTotal) AS TotalRevenue,
    SUM(p.StandardCost * sod.OrderQty) AS TotalCost,
    SUM(sod.LineTotal - (p.StandardCost * sod.OrderQty)) AS TotalProfit
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID;

----- (10)What is the Monthly Revenue,Profit

SELECT 
    FORMAT(soh.OrderDate, 'yyyy-MM') AS OrderMonth,
    SUM(sod.LineTotal) AS MonthlyRevenue,
    SUM(p.StandardCost * sod.OrderQty) AS MonthlyCost,
    SUM(sod.LineTotal - (p.StandardCost * sod.OrderQty)) AS MonthlyProfit
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY FORMAT(soh.OrderDate, 'yyyy-MM')
ORDER BY OrderMonth;

---(11)what is total profit for product

SELECT 
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS Revenue,
    SUM(p.StandardCost * sod.OrderQty) AS Cost,
    SUM(sod.LineTotal - (p.StandardCost * sod.OrderQty)) AS Profit
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY Profit DESC;

----(12)top 10 most profitable products

SELECT TOP 10 
    p.Name AS ProductName,
    SUM(sod.LineTotal - (p.StandardCost * sod.OrderQty)) AS TotalProfit
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalProfit DESC;


--(13) what is the profit by territory

SELECT 
    st.Name AS Territory,
    SUM(sod.LineTotal) AS Revenue,
    SUM(p.StandardCost * sod.OrderQty) AS Cost,
    SUM(sod.LineTotal - (p.StandardCost * sod.OrderQty)) AS Profit
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.Name;


----(14) Territory with the highest number of customers

SELECT TOP 1 t.Name, COUNT(c.CustomerID) AS CustomerCount
FROM Sales.Customer c
JOIN Sales.SalesTerritory t ON c.TerritoryID = t.TerritoryID
GROUP BY t.Name
ORDER BY CustomerCount DESC;

---(15) Products that are currently out of stock

SELECT p.Name, p.ProductID
FROM Production.Product p
WHERE p.ProductID NOT IN (
    SELECT ProductID 
    FROM Production.ProductInventory
    WHERE Quantity > 0);




