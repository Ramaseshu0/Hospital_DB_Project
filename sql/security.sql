-- Phase 1 Step 1.4: Security & RBAC

-- Create Roles
CREATE ROLE hospital_analyst WITH LOGIN PASSWORD 'analyst_pass';
CREATE ROLE hospital_admin WITH LOGIN PASSWORD 'admin_pass';

-- Grant Connect
GRANT CONNECT ON DATABASE hospital_db TO hospital_analyst;
GRANT CONNECT ON DATABASE hospital_db TO hospital_admin;

-- Analyst Permissions (Read-Only)
GRANT USAGE ON SCHEMA public TO hospital_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO hospital_analyst;

-- Admin Permissions (Read-Write)
GRANT USAGE ON SCHEMA public TO hospital_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hospital_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hospital_admin;