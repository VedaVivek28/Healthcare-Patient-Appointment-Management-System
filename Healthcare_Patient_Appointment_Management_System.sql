--Creating Patients Table
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dob DATE,
    gender CHAR(1),
    phone VARCHAR(15) UNIQUE,
    email VARCHAR(100) UNIQUE,
    address NVARCHAR(255)
);

INSERT INTO Patients (first_name, last_name, dob, gender, phone, email, address)
VALUES
('Ravi', 'Kumar', '1990-05-12', 'M', '9876543210', 'ravi.kumar@example.com', 'Hyderabad, India'),
('Anita', 'Sharma', '1985-09-23', 'F', '9123456780', 'anita.sharma@example.com', 'Delhi, India'),
('Sunil', 'Verma', '1978-11-04', 'M', '9988776655', 'sunil.verma@example.com', 'Mumbai, India'),
('Priya', 'Menon', '1995-02-18', 'F', '9090909090', 'priya.menon@example.com', 'Chennai, India'),
('Arjun', 'Patel', '2000-07-30', 'M', '9876501234', 'arjun.patel@example.com', 'Ahmedabad, India');

--Creating Doctors Table
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialization VARCHAR(100),
    phone VARCHAR(15) UNIQUE,
    email VARCHAR(100) UNIQUE
);

INSERT INTO Doctors (first_name, last_name, specialization, phone, email)
VALUES
('Rajesh', 'Gupta', 'Cardiologist', '8881112222', 'rajesh.gupta@hospital.com'),
('Meena', 'Nair', 'Dermatologist', '8883334444', 'meena.nair@hospital.com'),
('Suresh', 'Iyer', 'Orthopedic', '8885556666', 'suresh.iyer@hospital.com'),
('Lakshmi', 'Reddy', 'Pediatrician', '8887778888', 'lakshmi.reddy@hospital.com'),
('Vikram', 'Singh', 'General Physician', '8889990000', 'vikram.singh@hospital.com');

--Creating Appointments Table
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY IDENTITY(1,1),
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME,
    status VARCHAR(20) DEFAULT 'Scheduled',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status)
VALUES
(1, 1, '2025-09-01 10:30:00', 'Completed'),
(2, 3, '2025-09-02 11:00:00', 'Scheduled'),
(3, 5, '2025-09-03 09:45:00', 'Completed'),
(4, 2, '2025-09-04 14:15:00', 'Cancelled'),
(5, 4, '2025-09-05 16:00:00', 'Scheduled');

--Creating Prescription Table
CREATE TABLE Prescriptions (
    prescription_id INT PRIMARY KEY IDENTITY(1,1),
    appointment_id INT,
    medicine_name VARCHAR(100),
    dosage VARCHAR(50),
    duration_days INT,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

INSERT INTO Prescriptions (appointment_id, medicine_name, dosage, duration_days)
VALUES
(1, 'Atorvastatin', '10mg once daily', 30),
(2, 'Ibuprofen', '400mg twice daily', 5),
(3, 'Amoxicillin', '500mg three times daily', 7),
(4, 'Cetirizine', '10mg once daily', 10),
(5, 'Paracetamol', '500mg as needed', 3);

--Creating Lab Tests Table
CREATE TABLE LabTests (
    test_id INT PRIMARY KEY IDENTITY(1,1),
    appointment_id INT,
    test_name VARCHAR(100),
    status VARCHAR(20) DEFAULT 'Pending',
    report_date DATE,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

INSERT INTO LabTests (appointment_id, test_name, status, report_date)
VALUES
(1, 'Blood Test', 'Completed', '2025-09-02'),
(2, 'X-Ray', 'Pending', NULL),
(3, 'ECG', 'Completed', '2025-09-03'),
(4, 'Allergy Test', 'Pending', NULL),
(5, 'Urine Test', 'Pending', NULL);

--Creating Billing Table
CREATE TABLE Billing (
    bill_id INT PRIMARY KEY IDENTITY(1,1),
    appointment_id INT,
    amount DECIMAL(10,2),
    paid BIT DEFAULT 0,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

INSERT INTO Billing (appointment_id, amount, paid)
VALUES
(1, 2000.00, 1),
(2, 1500.00, 0),
(3, 3000.00, 1),
(4, 1200.00, 0),
(5, 1800.00, 1);

CREATE UNIQUE INDEX idx_doctor_schedule
ON Appointments(doctor_id, appointment_date);

CREATE PROCEDURE CancelUnpaidBills
AS
BEGIN
    UPDATE a
    SET status = 'Cancelled'
    FROM Appointments a
    INNER JOIN Billing b ON a.appointment_id = b.appointment_id
    WHERE b.paid = 0 
      AND DATEDIFF(DAY, a.appointment_date, GETDATE()) > 30;
END;

--Frequent Patients (Top 5 Visitors)
SELECT TOP 5 
    p.first_name, 
    p.last_name, 
    COUNT(*) AS visit_count
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
GROUP BY p.first_name, p.last_name
ORDER BY visit_count DESC;

--High-Demand Doctors (Top 3 by Appointments)
SELECT TOP 3 
    d.first_name, 
    d.last_name, 
    d.specialization, 
    COUNT(*) AS total_appointments
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.first_name, d.last_name, d.specialization
ORDER BY total_appointments DESC;

--Treatment Success Rate (Completed vs Total per Doctor)
SELECT 
    d.first_name, 
    d.last_name,
    CAST(SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) * 100.0 
         / COUNT(*) AS DECIMAL(5,2)) AS success_rate
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.first_name, d.last_name;

--Pending Lab Reports
SELECT 
    t.test_name, 
    p.first_name, 
    p.last_name, 
    a.appointment_date
FROM LabTests t
JOIN Appointments a ON t.appointment_id = a.appointment_id
JOIN Patients p ON a.patient_id = p.patient_id
WHERE t.status = 'Pending';

-- Prescriptions Ending in Next 3 Days
SELECT 
    pr.medicine_name, 
    p.first_name, 
    p.last_name,
    DATEADD(DAY, pr.duration_days, a.appointment_date) AS medicine_completion_date
FROM Prescriptions pr
JOIN Appointments a ON pr.appointment_id = a.appointment_id
JOIN Patients p ON a.patient_id = p.patient_id
WHERE DATEADD(DAY, pr.duration_days, a.appointment_date) 
      <= DATEADD(DAY, 3, GETDATE());

--Monthly Revenue from Billing
SELECT 
    YEAR(a.appointment_date) AS Year,
    MONTH(a.appointment_date) AS Month,
    SUM(b.amount) AS Total_Revenue,
    SUM(CASE WHEN b.paid = 1 THEN b.amount ELSE 0 END) AS Collected_Revenue,
    SUM(CASE WHEN b.paid = 0 THEN b.amount ELSE 0 END) AS Pending_Revenue
FROM Billing b
JOIN Appointments a ON b.appointment_id = a.appointment_id
GROUP BY YEAR(a.appointment_date), MONTH(a.appointment_date)
ORDER BY Year, Month;

--Prevent inserting appointments in the past
CREATE TRIGGER trg_PreventPastAppointments
ON Appointments
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE i.appointment_date < GETDATE()
    )
    BEGIN
        RAISERROR('Cannot schedule an appointment in the past.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--SQL Agent Job Setup Script for canceling unpaid bills
USE msdb;
GO

-- 1. Create a new SQL Agent Job
EXEC sp_add_job 
    @job_name = N'Cancel Unpaid Bills Job',
    @enabled = 1,
    @description = N'Cancels appointments with unpaid bills older than 30 days';

-- 2. Add a job step (execute stored procedure)
EXEC sp_add_jobstep
    @job_name = N'Cancel Unpaid Bills Job',
    @step_name = N'Run CancelUnpaidBills Procedure',
    @subsystem = N'TSQL',
    @command = N'EXEC CancelUnpaidBills;',
    @retry_attempts = 1,
    @retry_interval = 5;

-- 3. Create a daily schedule (runs at 12:00 AM)
EXEC sp_add_schedule 
    @schedule_name = N'Daily Midnight Schedule',
    @freq_type = 4,               -- daily
    @freq_interval = 1,           -- every 1 day
    @active_start_time = 000000;  -- 12:00 AM

-- 4. Attach the schedule to the job
EXEC sp_attach_schedule
    @job_name = N'Cancel Unpaid Bills Job',
    @schedule_name = N'Daily Midnight Schedule';

-- 5. Add the job to SQL Server Agent
EXEC sp_add_jobserver
    @job_name = N'Cancel Unpaid Bills Job';
GO
