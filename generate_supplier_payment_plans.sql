/*
Calculate months remaining to invoice due date (starting from end of this month)
Calculate monthly payment per invoice = invoice_amount / months_remaining
Generate a payment schedule per invoice, per month
Aggregate monthly payments per supplier
Calculate balance outstanding per supplier per payment month
*/

--Calculates months left until invoice due date
WITH months_calc AS (
    SELECT
        inv.supplier_id,
        inv.invoice_ammount,
        inv.due_date,
        date_add('day', -day_of_month(date_add('month', 1, CURRENT_DATE)), date_add('month', 1, CURRENT_DATE)) AS payment_start_date,
        ((year(inv.due_date) - year(date_add('day', -day_of_month(date_add('month', 1, CURRENT_DATE)), date_add('month', 1, CURRENT_DATE)))) * 12) +
         (month(inv.due_date) - month(date_add('day', -day_of_month(date_add('month', 1, CURRENT_DATE)), date_add('month', 1, CURRENT_DATE)))) AS months_remaining
    FROM memory.default.invoice inv
),

--Computes monthly payment per invoice
invoice_payments AS (
    SELECT
        supplier_id,
        invoice_ammount,
        due_date,
        payment_start_date,
        CAST(months_remaining AS INTEGER) AS months_remaining,
        invoice_ammount / CAST(months_remaining AS DOUBLE) AS monthly_payment
    FROM months_calc
    WHERE months_remaining > 0
),

--Generates each monthly payment and reduces balance per invoice
recursive_payments AS (
    SELECT
        supplier_id,
        invoice_ammount,
        due_date,
        monthly_payment,
        payment_start_date AS payment_date,
        invoice_ammount AS balance_outstanding,
        1 AS month_num,
        months_remaining
    FROM invoice_payments

    UNION ALL

    SELECT
        rp.supplier_id,
        rp.invoice_ammount,
        rp.due_date,
        rp.monthly_payment,
        date_add('day', -day_of_month(date_add('month', 1, rp.payment_date)), date_add('month', 1, rp.payment_date)) AS payment_date,
        rp.balance_outstanding - rp.monthly_payment AS balance_outstanding,
        rp.month_num + 1 AS month_num,
        rp.months_remaining
    FROM recursive_payments rp
    WHERE rp.month_num < rp.months_remaining
      AND rp.balance_outstanding - rp.monthly_payment > 0
),

--Aggregate per supplier per month
supplier_monthly_payments AS (
    SELECT
        supplier_id,
        payment_date,
        SUM(monthly_payment) AS payment_amount
    FROM recursive_payments
    GROUP BY supplier_id, payment_date
),

--Calculate balance outstanding per supplier at each payment_date
supplier_balances AS (
    SELECT
        supplier_id,
        payment_date,
        SUM(GREATEST(balance_outstanding, 0)) AS balance_outstanding
    FROM recursive_payments
    GROUP BY supplier_id, payment_date
),

--Join suppliers to get supplier_name
final_schedule AS (
    SELECT
        smp.supplier_id,
        sup.name AS supplier_name,
        smp.payment_amount,
        sb.balance_outstanding,
        smp.payment_date
    FROM supplier_monthly_payments smp
    JOIN supplier_balances sb
      ON smp.supplier_id = sb.supplier_id AND smp.payment_date = sb.payment_date
    JOIN memory.default.supplier sup
      ON smp.supplier_id = sup.supplier_id
)

SELECT
    supplier_id,
    supplier_name,
    payment_amount,
    balance_outstanding,
    payment_date
FROM final_schedule
ORDER BY supplier_id, payment_date;
