# Healthcare-Patient-Appointment-Management-System
his project is a Healthcare Management Database designed in SQL Server to manage patients, doctors, appointments, prescriptions, lab tests, and billing. It enforces business rules (constraints, triggers, stored procedures) and provides analytics (monthly revenue, patient frequency, treatment success rates etc.) for hospital/clinic operations.
🗂 Database Schema
Entities:
Patients – stores patient details
Doctors – stores doctor details and specialization
Appointments – tracks visits between patients and doctors
Prescriptions – medicines prescribed with dosage & duration
LabTests – lab tests assigned with status and report dates
Billing – payment details for appointments

Schema Diagram (ERD):
Patients --< Appointments >-- Doctors
Appointments --< Prescriptions
Appointments --< LabTests
Appointments --< Billing

⚙️ Features
✅ Enforced data integrity using foreign keys and constraints
✅ Unique index to prevent doctor double-booking
✅ Stored procedure to auto-cancel unpaid bills after 30 days
✅ SQL Agent job for automated tasks (billing, pending labs)
✅ Analytics queries for business insights

💾 Sample Data (5 rows per table)
-- Patients
INSERT INTO Patients (first_name, last_name, dob, gender, phone, email, address)
VALUES
('Ravi', 'Kumar', '1990-05-12', 'M', '9876543210', 'ravi.kumar@example.com', 'Hyderabad, India'),
('Anita', 'Sharma', '1985-09-23', 'F', '9123456780', 'anita.sharma@example.com', 'Delhi, India'),
('Sunil', 'Verma', '1978-11-04', 'M', '9988776655', 'sunil.verma@example.com', 'Mumbai, India'),
('Priya', 'Menon', '1995-02-18', 'F', '9090909090', 'priya.menon@example.com', 'Chennai, India'),
('Arjun', 'Patel', '2000-07-30', 'M', '9876501234', 'arjun.patel@example.com', 'Ahmedabad, India');

📊 Example Queries
1. Frequent Patients
SELECT TOP 5 
    p.first_name, p.last_name, COUNT(*) AS visit_count
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
GROUP BY p.first_name, p.last_name
ORDER BY visit_count DESC;

2. High-Demand Doctors
SELECT TOP 3 
    d.first_name, d.last_name, d.specialization, COUNT(*) AS total_appointments
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.first_name, d.last_name, d.specialization
ORDER BY total_appointments DESC;

📈 Example Reports
📌 Top 5 frequent patients
📌 Top 3 most-demanded doctors
📌 Monthly revenue breakdown (paid vs pending)

🛠 Tech Stack
SQL Server (DDL, DML, Stored Procedures, Triggers, Indexes)
ERD 
SQL Agent Jobs for canceling unpaid bills
