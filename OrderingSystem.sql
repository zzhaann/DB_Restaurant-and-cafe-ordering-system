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
