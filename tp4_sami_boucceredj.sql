-- Multimedia --

DROP TABLE images;

-- Creation de la table image --
CREATE TABLE images (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    image ORDImage
);


-- indice 1 --
-- Insertion des images --

DECLARE
    img_obj ORDImage;
    img_ctx RAW(64) := NULL; -- set to NULL because of the ORDImage.import() function 
--requirements
 ...
BEGIN
--Insert a new tuple into the images table. We initialize the image attribute value. 
    INSERT INTO images (id, name, image)
    VALUES (<id>, <srcName>, ORDSYS.ORDImage.init());
    --Define an implicit cursor to update the initialized image attribute
    SELECT image INTO img_obj FROM images WHERE name = <srcName>
    FOR UPDATE;
    --Import the image into the img_obj and update the table
    img_obj.importFrom(img_ctx, <srcType>, <srcLocation>, <srcName>);
    UPDATE images SET image = img_obj WHERE name = <srcName>;
    COMMIT;
END;
/

-- indice 2 --
DECLARE
... 
TYPE names_t IS TABLE OF VARCHAR2(30);
    img_names names_t := names_t('arbre1.jpg', 'arbre2.jpg', ...);
 
BEGIN
    FOR i IN img_names.first..img_names.last loop
    --Insert image with name img_names(i).
    ...
    END LOOP;
END;
/


-- solution --
DECLARE
    img_obj ORDImage;
    img_ctx RAW(64) := NULL;
    img_names SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(
        'arbre1.jpg', 'arbre2.jpg', 'arbre3.jpg',
        'bus1.jpg', 'bus2.jpg',
        'mer1.jpg', 'mer2.jpg',
        'vache1.jpg', 'vache2.jpg', 'vache3.jpg'
    );
BEGIN
    FOR i IN img_names.FIRST .. img_names.LAST LOOP
        -- Insert a new tuple into the images table
        INSERT INTO images (id, name, image)
        VALUES (i, img_names(i), ORDSYS.ORDImage.init());

        -- Define an implicit cursor to update the initialized image attribute
        SELECT image INTO img_obj FROM images WHERE name = img_names(i) FOR UPDATE;

        -- Import the image into img_obj and update the table
        img_obj.importFrom(img_ctx, 'file', 'IMG', img_names(i));
        UPDATE images SET image = img_obj WHERE name = img_names(i);
        COMMIT;
    END LOOP;
END;
/



-- requete affichant le nom et la taille des images commencant par la lettre 'a' --
SET SERVEROUTPUT ON;

DECLARE
   CURSOR image_cursor IS
      SELECT name, image
      FROM images
      WHERE UPPER(SUBSTR(name, 1, 1)) = 'A'; -- Assuming case-insensitive comparison

   image_name images.name%TYPE;
   image_data ORDSYS.ORDImage;
   content_length INTEGER;
BEGIN
   OPEN image_cursor;
   LOOP
      FETCH image_cursor INTO image_name, image_data;
      EXIT WHEN image_cursor%NOTFOUND;

      -- Get the image size:
      content_length := image_data.getContentLength();
      DBMS_OUTPUT.PUT_LINE('Image Name: ' || image_name || ', Image Size: ' || content_length);
   END LOOP;

   CLOSE image_cursor;
END;
/



-- Spatial --

-- Creation des tables monuments et shops avec location de type SDO_GEOMETRY --
-- Create table monuments
CREATE TABLE monuments (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    street_address VARCHAR2(255),
    city VARCHAR2(50),
    postal_code VARCHAR2(10),
    location SDO_GEOMETRY
);

-- Create table shops
CREATE TABLE shops (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    street_address VARCHAR2(255),
    city VARCHAR2(50),
    postal_code VARCHAR2(10),
    location SDO_GEOMETRY,
    monument_id NUMBER,
    FOREIGN KEY (monument_id) REFERENCES monuments(id)
);
