/*Таблица құру үшін*/
CREATE TABLE Customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    address TEXT
);

CREATE TABLE Categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);


CREATE TABLE MenuItems (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT REFERENCES Categories(id),
    price DECIMAL(10,2) NOT NULL,
    available BOOLEAN DEFAULT TRUE
);



CREATE TABLE Orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(id),
    status VARCHAR(50) CHECK (status IN ('pending', 'preparing', 'ready', 'completed', 'canceled')) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE OrderDetails (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(id) ON DELETE CASCADE,
    menu_item_id INT REFERENCES MenuItems(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE PaymentMethods (
    id SERIAL PRIMARY KEY,
    method VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Payments (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(id) ON DELETE CASCADE,
    payment_method_id INT REFERENCES PaymentMethods(id),
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('pending', 'paid', 'failed')) NOT NULL
);

CREATE TABLE Promotions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2) CHECK (discount_percentage BETWEEN 0 AND 100),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL
);

CREATE TABLE OrderPromotions (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(id) ON DELETE CASCADE,
    promotion_id INT REFERENCES Promotions(id)
);

CREATE TABLE MenuItemPromotions (
    id SERIAL PRIMARY KEY,
    menu_item_id INT REFERENCES MenuItems(id) ON DELETE CASCADE,
    promotion_id INT REFERENCES Promotions(id) ON DELETE CASCADE
);

CREATE TABLE Deliveries (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(id) ON DELETE CASCADE,
    delivery_address TEXT NOT NULL,
    estimated_time INTERVAL NOT NULL,
    status VARCHAR(50) CHECK (status IN ('pending', 'on the way', 'delivered')) NOT NULL
);

CREATE TABLE Reviews (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(id),
    order_id INT REFERENCES Orders(id) ON DELETE SET NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5) NOT NULL,
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE LoyaltyProgram (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(id),
    points INT DEFAULT 0
);

CREATE TABLE TableReservations (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(id),
    reservation_time TIMESTAMP NOT NULL,
    guests_count INT CHECK (guests_count > 0) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('pending', 'confirmed', 'canceled')) NOT NULL
);

CREATE TABLE OrderHistory (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(id) ON DELETE CASCADE,
    status VARCHAR(50) CHECK (status IN ('pending', 'preparing', 'ready', 'completed', 'canceled')) NOT NULL,
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




--рөл құру
create role data_manager_role;
create role order_manager_role;
create role waiter_role;
create role courier_role;
create role customer_role;
-- құрылған рөлдерді қөру
select rolname from pg_roles
where rolname in ('data_manager_role', 'order_manager_role', 'waiter_role','courier_role','customer_role')  ;

--привилигия беру
GRANT CREATE ON DATABASE order_system TO data_manager_role;
GRANT CREATE ON SCHEMA public TO data_manager_role;
grant all privileges on all tables in schema public to data_manager_role;
grant select, insert, update, delete on orders, tablereservations, orderdetails to order_manager_role;
grant select, insert on  Orders, MenuItems to waiter_role;
grant select, update on Deliveries, Orders to courier_role;
grant SELECT, INSERT on MenuItems, Orders, Reviews to customer_role;

--қолданушы құру
create user data_manager with password '1234Aa';
create user order_manager with password '1234Aa';
create user waiter with password '1234Aa';
create user courier with password '1234Aa';
create user customer with password '1234Aa';

--қолданушыға рөлдерді беру
grant data_manager_role to data_manager;
grant order_manager_role to order_manager;
grant waiter_role to waiter;
grant courier_role to courier;
grant customer_role to customer;
ALTER DATABASE postgres OWNER TO data_manager;

--рөл және олардың қолданушылары
SELECT u.rolname AS user_name, r.rolname AS role_name
FROM pg_catalog.pg_roles AS u
LEFT JOIN pg_catalog.pg_auth_members AS m ON u.oid = m.member
LEFT JOIN pg_catalog.pg_roles AS r ON m.roleid = r.oid
where r.rolname in ('data_manager_role', 'order_manager_role', 'waiter_role','courier_role','customer_role')
ORDER BY user_name;


--привилигия көру үшін
SELECT grantee AS user_name,
       STRING_AGG(privilege_type, ', ') AS privileges,
       STRING_AGG(table_name, ', ') AS tables
FROM information_schema.role_table_grants
WHERE grantee IN ('data_manager_role', 'order_manager_role', 'waiter_role', 'courier_role', 'customer_role')
GROUP BY grantee
ORDER BY user_name;


-- барлық шектеулерді шығару үшін
SELECT conname AS constraint_name,
       contype AS constraint_type,
       conrelid::regclass AS table_name
FROM pg_constraint
ORDER BY table_name, constraint_type;


--check
SELECT conname AS constraint_name,
       conrelid::regclass AS table_name,
       pg_get_constraintdef(oid) AS search_condition
FROM pg_constraint
WHERE contype = 'c'
ORDER BY table_name;



--праймари кейлер
SELECT conname AS constraint_name,
       conrelid::regclass AS table_name
FROM pg_constraint
WHERE contype = 'p'
ORDER BY table_name;

--форейн кейс
SELECT conname AS constraint_name,
       conrelid::regclass AS table_name
FROM pg_constraint
WHERE contype = 'f'
ORDER BY table_name;

--unique
SELECT conname AS constraint_name,
       conrelid::regclass AS table_name
FROM pg_constraint
WHERE contype = 'u'
ORDER BY table_name;


-- Заполнение таблицы Customers (Клиенты)
INSERT INTO Customers (name, phone, email, address) VALUES
('Алихан Тулеуов', '+77710001122', 'alihan@mail.com', 'Алматы, ул. Абая 10'),
('Айжан Садыкова', '+77723334455', 'aizhan@mail.com', 'Нур-Султан, ул. Тауелсиздик 5'),
('Ерболат Касымов', '+77736667788', 'erbolat@mail.com', 'Шымкент, ул. Байтурсынова 15');

-- Заполнение таблицы Categories (Категории блюд)
INSERT INTO Categories (name) VALUES
('Горячие блюда'),
('Салаты'),
('Напитки');

-- Заполнение таблицы MenuItems (Меню)
INSERT INTO MenuItems (name, description, category_id, price, available) VALUES
('Плов', 'Традиционный узбекский плов', 1, 1800.00, TRUE),
('Цезарь', 'Салат с курицей и соусом цезарь', 2, 1500.00, TRUE),
('Лимонад', 'Домашний лимонад с мятой', 3, 600.00, TRUE);

-- Заполнение таблицы Orders (Заказы)
INSERT INTO Orders (customer_id, status, total_price, order_time) VALUES
(1, 'pending', 3600.00, NOW()),
(2, 'preparing', 1500.00, NOW()),
(3, 'ready', 600.00, NOW());

-- Заполнение таблицы OrderDetails (Детали заказа)
INSERT INTO OrderDetails (order_id, menu_item_id, quantity, price) VALUES
(1, 1, 2, 3600.00),
(2, 2, 1, 1500.00),
(3, 3, 1, 600.00);

-- Заполнение таблицы PaymentMethods (Методы оплаты)
INSERT INTO PaymentMethods (method) VALUES
('Наличные'),
('Банковская карта'),
('QR-код Kaspi');

-- Заполнение таблицы Payments (Платежи)
INSERT INTO Payments (order_id, payment_method_id, amount, status) VALUES
(1, 2, 3600.00, 'paid'),
(2, 3, 1500.00, 'pending'),
(3, 1, 600.00, 'paid');

-- Заполнение таблицы Promotions (Акции)
INSERT INTO Promotions (name, description, discount_percentage, start_date, end_date) VALUES
('Скидка 10% на плов', 'Акция на традиционный плов', 10, NOW(), NOW() + INTERVAL '7 days'),
('Бесплатный напиток', 'При заказе на сумму от 3000 тенге', 100, NOW(), NOW() + INTERVAL '10 days');

-- Заполнение таблицы OrderPromotions (Связь заказов и акций)
INSERT INTO OrderPromotions (order_id, promotion_id) VALUES
(1, 1);

-- Заполнение таблицы MenuItemPromotions (Связь меню и акций)
INSERT INTO MenuItemPromotions (menu_item_id, promotion_id) VALUES
(1, 1);

-- Заполнение таблицы Deliveries (Доставки)
INSERT INTO Deliveries (order_id, delivery_address, estimated_time, status) VALUES
(1, 'Алматы, ул. Абая 10', '30 minutes', 'on the way'),
(2, 'Нур-Султан, ул. Тауелсиздик 5', '45 minutes', 'pending');

-- Заполнение таблицы Reviews (Отзывы)
INSERT INTO Reviews (customer_id, order_id, rating, comment, review_date) VALUES
(1, 1, 5, 'Очень вкусный плов!', NOW()),
(2, 2, 4, 'Цезарь был свежий, но хотелось больше соуса.', NOW());

-- Заполнение таблицы LoyaltyProgram (Программа лояльности)
INSERT INTO LoyaltyProgram (customer_id, points) VALUES
(1, 100),
(2, 50);

-- Заполнение таблицы TableReservations (Бронирование столов)
INSERT INTO TableReservations (customer_id, reservation_time, guests_count, status) VALUES
(3, NOW() + INTERVAL '1 day', 2, 'confirmed');

-- Заполнение таблицы OrderHistory (История заказов)
INSERT INTO OrderHistory (order_id, status, change_time) VALUES
(1, 'preparing', NOW() - INTERVAL '10 minutes'),
(1, 'ready', NOW());

--ЗАПРОСЫ барлық клинеттерді алу
SELECT * FROM Customers;

--Төлемдердің жалпы сомасын есептеу
SELECT SUM(amount) AS total_payments FROM Payments;

--Клиенттердің ең көп тапсырыс берген тағамдарын табу
WITH OrderCounts AS (
    SELECT
        o.customer_id,
        od.menu_item_id,
        COUNT(od.menu_item_id) AS order_count
    FROM Orders o
    JOIN OrderDetails od ON o.id = od.order_id
    GROUP BY o.customer_id, od.menu_item_id
), RankedOrders AS (
    SELECT
        oc.customer_id,
        oc.menu_item_id,
        oc.order_count,
        RANK() OVER (PARTITION BY oc.customer_id ORDER BY oc.order_count DESC) AS rank
    FROM OrderCounts oc
)
SELECT
    c.name AS customer_name,
    m.name AS most_ordered_dish,
    ro.order_count
FROM RankedOrders ro
JOIN Customers c ON ro.customer_id = c.id
JOIN MenuItems m ON ro.menu_item_id = m.id
WHERE ro.rank = 1;


--Әр ай бойынша жалпы табыс және орташа чек сомасын есептеу.
SELECT
    DATE_TRUNC('month', order_time) AS month,
    COUNT(id) AS total_orders,
    SUM(total_price) AS total_revenue,
    AVG(total_price) AS average_order_value
FROM Orders
GROUP BY month
ORDER BY month DESC;

--Соңғы 3 айда акциялар қолданылған тапсырыстарды табу
SELECT
    o.id AS order_id,
    c.name AS customer_name,
    SUM(o.total_price * (p.discount_percentage / 100)) AS total_discount,
    o.total_price - SUM(o.total_price * (p.discount_percentage / 100)) AS final_price
FROM Orders o
JOIN OrderPromotions op ON o.id = op.order_id
JOIN Promotions p ON op.promotion_id = p.id
JOIN Customers c ON o.customer_id = c.id
WHERE o.order_time >= NOW() - INTERVAL '3 months'
GROUP BY o.id, c.name, order_time
ORDER BY o.order_time DESC;


