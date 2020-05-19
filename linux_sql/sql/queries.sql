-- connect to host_agent database
\c host_agent

-- round time function (5 min interval)
CREATE FUNCTION round_time(TIMESTAMP WITH TIME ZONE) RETURNS TIMESTAMP WITH TIME ZONE AS $$
SELECT
  date_trunc('hour', $1) + INTERVAL '5 min' * ROUND(
    date_part('minute', $1) / 5.0
  ) $$ LANGUAGE SQL;

-- Total memory size for respective hosts
SELECT
  cpu_number,
  id as host_id,
  total_mem
FROM
  host_info
ORDER BY
  cpu_number,
  total_mem desc;

-- Average percentage of used memory for respective hosts (average is captured every 5 minutes)
SELECT
  DISTINCT tblB.host_id,
  tblA.hostname,
  round_time(tblB.timestamp) AS timestamp,
  round(
    avg(
      (
        (
          (
            tblA.total_mem - tblB.memory_free * 1000
          )/(1.0 * tblA.total_mem)
        )* 100
      )
    ) OVER(
      PARTITION BY tblB.host_id,
      round_time(tblB.timestamp)
    )
  ) AS avg_used_mem_percentage
FROM
  host_info tblA
  LEFT JOIN host_usage tblB ON tblB.host_id = tblA.id
ORDER BY
  host_id;
