/*
JOIN between employee and expense to link each expense to its employee
LEFT JOIN to employee again to get the manager's name
GROUP BY to calculate total expenses per employee
HAVING clause to filter only those with more than 1000 total expensed amount
*/

SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.manager_id,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
    SUM(ex.unit_price * ex.quantity) AS total_expensed_amount
FROM memory.default.employee e
JOIN memory.default.expense ex
    ON e.employee_id = ex.employee_id
LEFT JOIN memory.default.employee m
    ON e.manager_id = m.employee_id
GROUP BY 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.manager_id,
    m.first_name,
    m.last_name
HAVING 
    SUM(ex.unit_price * ex.quantity) > 1000
ORDER BY 
    total_expensed_amount DESC;
