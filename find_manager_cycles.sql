/*Since there's no explicit expense_approval table, 
we can infer approval relationships based on manager hierarchy — 
i.e., a manager implicitly "approves" their direct report's expenses.

I’ll define an approval relationship as:
An employee's manager approves their expenses.

This forms a directed graph, where:
An edge exists from requester_id → approver_id (employee_id → manager_id)
If managers also have their own managers, this structure can form cycles.
The goal is to detect cycles in this approval graph.

Starts from each employee and follows their manager chain.
Builds a path as an array of employee IDs.
If the path loops back to the starting employee (start_id = current_id), it's a cycle.
Prevents infinite loops with visited tracking.
*/


WITH RECURSIVE approval_path (start_id, current_id, path, visited) AS (
    -- Base case: start with each employee and their manager
    SELECT 
        employee_id AS start_id,
        manager_id AS current_id,
        ARRAY[employee_id, manager_id] AS path,
        ARRAY[employee_id, manager_id] AS visited
    FROM memory.default.employee
    WHERE manager_id IS NOT NULL

    UNION ALL

    -- Recursive case: follow the manager chain
    SELECT
        ap.start_id,
        e.manager_id AS current_id,
        ap.path || e.manager_id,
        ap.visited || e.manager_id
    FROM approval_path ap
    JOIN memory.default.employee e
      ON ap.current_id = e.employee_id
    WHERE e.manager_id IS NOT NULL
      AND (NOT contains(ap.visited, e.manager_id) OR e.manager_id = ap.start_id)
)

-- Select cycles where the path returns to the original employee
SELECT 
    start_id AS employee_id,
    path AS approval_loop
FROM approval_path
WHERE current_id = start_id
  AND cardinality(path) > 2;
