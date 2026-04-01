-- Sample schema dump (scrubbed)
CREATE TABLE attendees (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  ticket_type VARCHAR(32),
  school VARCHAR(128)
);

CREATE TABLE ctf_teams (
  id INT PRIMARY KEY,
  team_name VARCHAR(128),
  captain_email VARCHAR(255)
);

-- No rows included in this export.
