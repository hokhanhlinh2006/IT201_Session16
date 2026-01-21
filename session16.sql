/* =========================================================
   ÔN TẬP TỔNG HỢP CSDL – QUẢN LÝ BÁN HÀNG
   Hệ quản trị: MySQL
   ========================================================= */

/* =========================
   CÂU 2 – TẠO CƠ SỞ DỮ LIỆU
   ========================= */
CREATE DATABASE IF NOT EXISTS quanlybanhang;
USE quanlybanhang;

/* =========================
   TẠO BẢNG
   ========================= */

-- Customers
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    address VARCHAR(255)
);

-- Products
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    category VARCHAR(50) NOT NULL
);

-- Employees
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    birthday DATE,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    revenue DECIMAL(10,2) DEFAULT 0
);

-- Orders
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- OrderDetails
CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

/* =========================
   CÂU 3 – CHỈNH SỬA BẢNG
   ========================= */

-- Thêm email vào Customers
ALTER TABLE Customers
ADD email VARCHAR(100) NOT NULL UNIQUE;

-- Xóa ngày sinh trong Employees
ALTER TABLE Employees
DROP COLUMN birthday;

/* =========================
   CÂU 4 – CHÈN DỮ LIỆU
   ========================= */

-- Customers
INSERT INTO Customers (customer_name, phone, address, email) VALUES
('Nguyen Van A','0901111111','Ha Noi','a@gmail.com'),
('Tran Thi B','0902222222','Hai Phong','b@gmail.com'),
('Le Van C','0903333333','Da Nang','c@gmail.com'),
('Pham Thi D','0904444444','HCM','d@gmail.com'),
('Hoang Van E','0905555555','Thai Binh','e@gmail.com');

-- Products
INSERT INTO Products (product_name, price, quantity, category) VALUES
('Laptop HP',1500,200,'Laptop'),
('Chuột Logitech',25,500,'Phụ kiện'),
('Bàn phím cơ',80,300,'Phụ kiện'),
('Màn hình Dell',250,150,'Monitor'),
('Tai nghe Sony',120,400,'Audio');

-- Employees
INSERT INTO Employees (employee_name, position, salary) VALUES
('Nguyen NV1','Sale',800),
('Tran NV2','Sale',850),
('Le NV3','Manager',1200),
('Pham NV4','Sale',780),
('Hoang NV5','Support',700);

-- Orders
INSERT INTO Orders (customer_id, employee_id) VALUES
(1,1),(2,2),(3,1),(1,3),(4,2);

-- OrderDetails
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES
(1,1,2,1500),
(1,2,5,25),
(2,3,3,80),
(3,1,1,1500),
(4,4,2,250);

/* =========================
   CÂU 5 – TRUY VẤN CƠ BẢN
   ========================= */

-- 5.1 Danh sách khách hàng
SELECT customer_id, customer_name, email, phone, address
FROM Customers;

-- 5.2 Cập nhật sản phẩm
UPDATE Products
SET product_name = 'Laptop Dell XPS',
    price = 99.99
WHERE product_id = 1;

-- 5.3 Thông tin đơn hàng
SELECT o.order_id,
       c.customer_name,
       e.employee_name,
       o.total_amount,
       o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id;

/* =========================
   CÂU 6 – TRUY VẤN ĐẦY ĐỦ
   ========================= */

-- 6.1 Số đơn mỗi khách hàng
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 6.2 Doanh thu nhân viên năm hiện tại
SELECT e.employee_id, e.employee_name,
       SUM(o.total_amount) AS revenue
FROM Employees e
JOIN Orders o ON e.employee_id = o.employee_id
WHERE YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY e.employee_id, e.employee_name;

-- 6.3 Sản phẩm bán > 100 trong tháng
SELECT p.product_id, p.product_name,
       SUM(od.quantity) AS total_sold
FROM OrderDetails od
JOIN Orders o ON od.order_id = o.order_id
JOIN Products p ON od.product_id = p.product_id
WHERE MONTH(o.order_date) = MONTH(CURDATE())
  AND YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY p.product_id, p.product_name
HAVING total_sold > 100
ORDER BY total_sold DESC;

/* =========================
   CÂU 7 – TRUY VẤN NÂNG CAO
   ========================= */

-- 7.1 Khách chưa đặt hàng
SELECT c.customer_id, c.customer_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 7.2 Sản phẩm giá cao hơn trung bình
SELECT *
FROM Products
WHERE price > (SELECT AVG(price) FROM Products);

-- 7.3 Khách chi tiêu cao nhất
SELECT c.customer_id, c.customer_name,
       SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING total_spent = (
    SELECT MAX(t.total_spent)
    FROM (
        SELECT SUM(total_amount) AS total_spent
        FROM Orders
        GROUP BY customer_id
    ) t
);

/* =========================
   CÂU 8 – VIEW
   ========================= */

CREATE VIEW view_order_list AS
SELECT o.order_id, c.customer_name, e.employee_name,
       o.total_amount, o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id
ORDER BY o.order_date DESC;

CREATE VIEW view_order_detail_product AS
SELECT od.order_detail_id, p.product_name,
       od.quantity, od.unit_price
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
ORDER BY od.quantity DESC;

/* =========================
   CÂU 9 – STORED PROCEDURE
   ========================= */

DELIMITER $$

CREATE PROCEDURE proc_insert_employee(
    IN p_name VARCHAR(100),
    IN p_position VARCHAR(50),
    IN p_salary DECIMAL(10,2),
    OUT p_employee_id INT
)
BEGIN
    INSERT INTO Employees(employee_name, position, salary)
    VALUES (p_name, p_position, p_salary);

    SET p_employee_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE proc_get_orderdetails(IN p_order_id INT)
BEGIN
    SELECT *
    FROM OrderDetails
    WHERE order_id = p_order_id;
END$$

CREATE PROCEDURE proc_cal_total_amount_by_order(IN p_order_id INT)
BEGIN
    SELECT COUNT(DISTINCT product_id) AS total_products
    FROM OrderDetails
    WHERE order_id = p_order_id;
END$$

/* =========================
   CÂU 10 – TRIGGER
   ========================= */

CREATE TRIGGER trigger_after_insert_order_details
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    IF (SELECT quantity FROM Products WHERE product_id = NEW.product_id) < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số lượng sản phẩm trong kho không đủ';
    ELSE
        UPDATE Products
        SET quantity = quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END$$

/* =========================
   CÂU 11 – TRANSACTION
   ========================= */

CREATE PROCEDURE proc_insert_order_details(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_price DECIMAL(10,2)
)
BEGIN
    DECLARE v_count INT;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count
    FROM Orders
    WHERE order_id = p_order_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'không tồn tại mã hóa đơn';
        ROLLBACK;
    ELSE
        INSERT INTO OrderDetails(order_id, product_id, quantity, unit_price)
        VALUES (p_order_id, p_product_id, p_quantity, p_price);

        UPDATE Orders
        SET total_amount = total_amount + (p_quantity * p_price)
        WHERE order_id = p_order_id;

        COMMIT;
    END IF;
END$$

DELIMITER ; ,,,
