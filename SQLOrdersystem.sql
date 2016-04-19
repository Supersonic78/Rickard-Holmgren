--• Lista alla order och dess attribut som inte är nycklar, samt kund och de produkter som ingår i ordern, 
--samt vilket fraktbolag ska skeppa ordern.

CREATE PROCEDURE GetAllOrders
AS
SELECT ProductName,Quantity, FirstName, LastName, SCompanyName, OrderDate, ShippingDate
FROM tblOrder
JOIN tblCustomer ON tblOrder.CustomerID = tblCustomer.CustomerID
JOIN tblShippingCompany ON tblOrder.SCompanyID = tblShippingCompany.SCompanyID
JOIN tblOrderLine ON tblOrder.OrderID = tblOrderLine.OrderID
JOIN tblProduct ON tblOrderLine.ProductID = tblProduct.ProductID
ORDER BY LastName
GO

EXEC GetAllOrders


--•• Lista alla order som en kund (Kunden ska kunna sökas med delar av efternamnet) 
--har och de produkter som ingår i ordern, samt vilket fraktbolag ska skeppa ordern.
GO
CREATE PROCEDURE GetAllOrdersByLastName @LastName nvarchar(50)
AS
SELECT ProductName,Quantity, FirstName, LastName, SCompanyName, OrderDate, ShippingDate
FROM tblOrder
JOIN tblCustomer ON tblOrder.CustomerID = tblCustomer.CustomerID
JOIN tblShippingCompany ON tblOrder.SCompanyID = tblShippingCompany.SCompanyID
JOIN tblOrderLine ON tblOrder.OrderID = tblOrderLine.OrderID
JOIN tblProduct ON tblOrderLine.ProductID = tblProduct.ProductID
WHERE LastName LIKE '%' + @LastName + '%'

GO

EXEC GetAllOrdersByLastName	'ba'


--•• Visa den order med mest produkter i.
GO
CREATE PROC GetOrderWithMostProd
AS
DECLARE @OrderID int
SELECT top 1 @OrderId = tblorder.OrderID
FROM tblOrder
JOIN tblOrderLine ON tblOrder.OrderID = tblOrderLine.OrderID
GROUP BY tblorder.orderid
ORDER BY COUNT(orderLineid) DESC
EXEC GetOrderInfoByOrderID @OrderID

EXEC GetOrderWithMostProd

CREATE PROC GetOrderInfoByOrderID(@OrderID int)
AS
SELECT ProductName,Quantity, FirstName, LastName, SCompanyName, OrderDate, ShippingDate
FROM tblOrder
JOIN tblCustomer ON tblOrder.CustomerID = tblCustomer.CustomerID
JOIN tblShippingCompany ON tblOrder.SCompanyID = tblShippingCompany.SCompanyID
JOIN tblOrderLine ON tblOrder.OrderID = tblOrderLine.OrderID
JOIN tblProduct ON tblOrderLine.ProductID = tblProduct.ProductID
WHERE tblOrder.OrderID = @OrderId

EXEC GetOrderWithMostProd



--•• Visa den dyraste ordern i systemet och kundens namn.
GO
ALTER PROC GetMostExpensiveOrder
AS
DECLARE @OrderId int
DECLARE @Sum money
SELECT top 1 @OrderId = orderid, @Sum = sum(Subtotal)
FROM
(

	SELECT orderid, ProductPrice * Quantity as SubTotal	
	FROM tblOrderLine
	JOIN tblProduct on tblOrderLine.ProductID = tblProduct.ProductID
	
) a
GROUP BY orderid
ORDER BY Sum(SubTotal) DESC



EXEC GetOrderInfoByOrderID @OrderID
SELECT @Sum AS Total

EXEC GetMostExpensiveOrder


--•• Visa alla order som ett fraktbolag skeppar. Ska kunna sökas med namnet på fraktbolaget.

ALTER PROCEDURE GetAllOrdersBySCName @SCName nvarchar(50)
AS
SELECT SCompanyName, OrderDate, ShippingDate, FirstName, LastName
FROM tblShippingCompany
JOIN tblOrder ON tblShippingCompany.SCompanyID = tblOrder.SCompanyID
JOIN tblCustomer ON tblOrder.CustomerID = tblCustomer.CustomerID
WHERE SCompanyName LIKE '%' + @SCName + '%'

GO

EXEC GetAllOrdersBySCName 'DHL'




--•• Visa alla order som ska skeppas på ett viss datum och fraktbolaget. Ska sökas med ett datum.

ALTER PROCEDURE GetAllOrdersByDate @Date date
AS
SELECT SCompanyName, ShippingDate, FirstName, LastName
FROM tblShippingCompany
JOIN tblOrder ON tblShippingCompany.SCompanyID = tblOrder.SCompanyID
JOIN tblCustomer ON tblOrder.CustomerID = tblCustomer.CustomerID
WHERE ShippingDate LIKE @Date

GO

EXEC GetAllOrdersByDate '2015-10-10'

--•• Visa antal order som ska skeppas för fraktbolagen.
GO
ALTER PROCEDURE GetOrderToBeShipped 
AS

SELECT SCompanyName, COUNT(*) AS 'NBR of orders to be shipped'
FROM tblOrder

JOIN tblShippingCompany ON tblOrder.SCompanyID = tblShippingCompany.SCompanyID

GROUP BY SCompanyName

GO

EXEC GetOrderToBeShipped



--•• Visa antal produkter som en tillverkare tillverkar. Ska sökas med namnet på fraktbolaget.
GO
ALTER PROCEDURE GetOrderByManuf @MFName nvarchar(50)
AS
SELECT ManufacturerName, COUNT(*) AS 'NBR of products Manufactured'
FROM tblManufacturer
JOIN tblProduct ON tblManufacturer.ManufacturerID = tblProduct.ManufacturerID
WHERE ManufacturerName LIKE '%' + @MFName + '%'
GROUP BY ManufacturerName

GO

EXEC GetOrderByManuf 'Clo'

