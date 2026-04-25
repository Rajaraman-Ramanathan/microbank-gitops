-- =========================
-- USERS / ROLES CREATION
-- =========================

-- account service user
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'accountuser') THEN
    CREATE ROLE accountuser LOGIN PASSWORD 'accountpass';
  END IF;
END
$$;

-- auth service user
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authuser') THEN
    CREATE ROLE authuser LOGIN PASSWORD 'authpass';
  END IF;
END
$$;

-- transaction service user
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'transactionuser') THEN
    CREATE ROLE transactionuser LOGIN PASSWORD 'transactionpass';
  END IF;
END
$$;

-- document service user
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'documentuser') THEN
    CREATE ROLE documentuser LOGIN PASSWORD 'documentpass';
  END IF;
END
$$;

-- keycloak user
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'keycloakuser') THEN
    CREATE ROLE keycloakuser LOGIN PASSWORD 'keycloakpass';
  END IF;
END
$$;