--connect to host_agent database
\c host_agent

--Create host_info table and insert a default row
CREATE TABLE IF NOT EXISTS PUBLIC.host_info (
  id SERIAL NOT NULL PRIMARY KEY,
  hostname VARCHAR NOT NULL UNIQUE,
  cpu_number SMALLINT NOT NULL,
  cpu_architecture VARCHAR NOT NULL,
  cpu_model VARCHAR NOT NULL,
  cpu_mhz FLOAT(3) NOT NULL,
  L2_cache INTEGER NOT NULL,
  total_mem INTEGER NOT NULL,
  "timestamp" TIMESTAMP NOT NULL
);
INSERT INTO host_info (
  id, hostname, cpu_number, cpu_architecture,
  cpu_model, cpu_mhz, L2_cache, total_mem,
  "timestamp"
)
VALUES
  (
    DEFAULT, 'spry-framework-236416.internal',
    1, 'x86_64', 'Intel(R) Xeon(R) CPU @ 2.30GHz',
    2300.000, 256, 601324, '2019-05-29 17:49:53'
  );

--Create host_usage table and insert a default row
CREATE TABLE IF NOT EXISTS PUBLIC.host_usage (
  "timestamp" TIMESTAMP NOT NULL,
  host_id INTEGER NOT NULL,
  memory_free INTEGER NOT NULL,
  cpu_idle SMALLINT NOT NULL,
  cpu_kernel SMALLINT NOT NULL,
  disk_io SMALLINT NOT NULL,
  disk_available INTEGER NOT NULL,
  FOREIGN KEY (host_id) REFERENCES host_info(id)
);
INSERT INTO host_usage (
  "timestamp", host_id, memory_free,
  cpu_idle, cpu_kernel, disk_io, disk_available
)
VALUES
  (
    '2019-05-29 16:53:28', 1, 256, 95,
    0, 0, 31220
  );
