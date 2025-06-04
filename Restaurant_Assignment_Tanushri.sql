CREATE TABLE Restaurant (
    restaurantId NUMBER PRIMARY KEY,
    restaurantName VARCHAR2(30),
    city VARCHAR2(30),
    email VARCHAR2(30),
    mobile VARCHAR2(15),
    rating NUMBER(5,2)
);

CREATE TABLE RestaurantBackup (
    RbId NUMBER PRIMARY KEY,
    restaurantId NUMBER,
    restaurantName VARCHAR2(30),
    city VARCHAR2(30),
    email VARCHAR2(30),
    mobile VARCHAR2(15),
    rating NUMBER(5,2),
    operation VARCHAR2(10),
    activityOn DATE DEFAULT SYSDATE
);

CREATE OR REPLACE PROCEDURE AddRestaurant (
    p_restaurantId NUMBER,
    p_restaurantName VARCHAR2,
    p_city VARCHAR2,
    p_email VARCHAR2,
    p_mobile VARCHAR2,
    p_rating NUMBER
) AS
BEGIN
    INSERT INTO Restaurant VALUES (p_restaurantId, p_restaurantName, p_city, p_email, p_mobile, p_rating);
END;
/

CREATE OR REPLACE PROCEDURE SearchByRestaurantId (
    p_restaurantId NUMBER
) AS
    v_name VARCHAR2(30);
    v_city VARCHAR2(30);
    v_email VARCHAR2(30);
BEGIN
    SELECT restaurantName, city, email INTO v_name, v_city, v_email
    FROM Restaurant
    WHERE restaurantId = p_restaurantId;

    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name || ', City: ' || v_city || ', Email: ' || v_email);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No restaurant found with ID ' || p_restaurantId);
END;
/

CREATE OR REPLACE PROCEDURE UpdateRestaurant (
    p_restaurantId NUMBER,
    p_restaurantName VARCHAR2,
    p_city VARCHAR2,
    p_email VARCHAR2,
    p_mobile VARCHAR2,
    p_rating NUMBER
) AS
BEGIN
    UPDATE Restaurant
    SET restaurantName = p_restaurantName,
        city = p_city,
        email = p_email,
        mobile = p_mobile,
        rating = p_rating
    WHERE restaurantId = p_restaurantId;
END;
/

CREATE OR REPLACE PROCEDURE DeleteRestaurantById (
    p_restaurantId NUMBER
) AS
BEGIN
    DELETE FROM Restaurant WHERE restaurantId = p_restaurantId;
END;
/

CREATE OR REPLACE PROCEDURE PrintAllRestaurants IS
    CURSOR restaurant_cur IS
        SELECT * FROM Restaurant;
    v_restaurant restaurant_cur%ROWTYPE;
BEGIN
    OPEN restaurant_cur;
    LOOP
        FETCH restaurant_cur INTO v_restaurant;
        EXIT WHEN restaurant_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_restaurant.restaurantId || ', Name: ' || v_restaurant.restaurantName);
    END LOOP;
    CLOSE restaurant_cur;
END;
/

CREATE SEQUENCE RestaurantBackup_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_insert
AFTER INSERT ON Restaurant
FOR EACH ROW
BEGIN
    INSERT INTO RestaurantBackup (RbId, restaurantId, restaurantName, city, email, mobile, rating, operation)
    VALUES (RestaurantBackup_seq.NEXTVAL, :NEW.restaurantId, :NEW.restaurantName, :NEW.city, :NEW.email, :NEW.mobile, :NEW.rating, 'INSERT');
END;
/

CREATE OR REPLACE TRIGGER trg_update
AFTER UPDATE ON Restaurant
FOR EACH ROW
BEGIN
    INSERT INTO RestaurantBackup (RbId, restaurantId, restaurantName, city, email, mobile, rating, operation)
    VALUES (RestaurantBackup_seq.NEXTVAL, :OLD.restaurantId, :OLD.restaurantName, :OLD.city, :OLD.email, :OLD.mobile, :OLD.rating, 'UPDATE');
END;
/

CREATE OR REPLACE TRIGGER trg_delete
AFTER DELETE ON Restaurant
FOR EACH ROW
BEGIN
    INSERT INTO RestaurantBackup (RbId, restaurantId, restaurantName, city, email, mobile, rating, operation)
    VALUES (RestaurantBackup_seq.NEXTVAL, :OLD.restaurantId, :OLD.restaurantName, :OLD.city, :OLD.email, :OLD.mobile, :OLD.rating, 'DELETE');
END;
/