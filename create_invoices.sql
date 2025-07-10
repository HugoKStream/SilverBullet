CREATE TABLE memory.default.INVOICE (
  supplier_id TINYINT ,
  invoice_ammount DECIMAL(8, 2) ,
  due_date DATE 
);

CREATE TABLE memory.default.SUPPLIER (
  supplier_id TINYINT ,
  name VARCHAR
);

INSERT INTO memory.default.SUPPLIER (supplier_id, name) VALUES
(1, 'Catering Plus'),
(2, 'Dave''s Discos'),
(3, 'Entertainment tonight'),
(4, 'Ice Ice Baby');

INSERT INTO memory.default.INVOICE (supplier_id, invoice_ammount, due_date) VALUES
-- Catering Plus
(1, 2000.00, DATE '2025-09-30'),
(1, 1500.00, DATE '2025-10-31'),

-- Dave's Discos
(2, 500.00, DATE '2025-08-31'),

-- Entertainment tonight
(3, 6000.00, DATE '2025-10-31'),

-- Ice Ice Baby
(4, 4000.00, DATE '2025-12-31');
