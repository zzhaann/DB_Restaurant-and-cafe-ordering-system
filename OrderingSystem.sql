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
