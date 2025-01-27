
USE basketball_management;


-- Create the Stadium table first
CREATE TABLE stadium (
    stadium_id INTEGER NOT NULL,
    stadium_name CHAR(30),
    location CHAR(30),
    capacity INTEGER,
    PRIMARY KEY (stadium_id)
);

-- Create the Team table next
CREATE TABLE team (
    team_id INTEGER NOT NULL,
    team_name CHAR(30),
    revenue INTEGER,
    stadium_id INTEGER NOT NULL,
    PRIMARY KEY (team_id),
    FOREIGN KEY (stadium_id) REFERENCES stadium(stadium_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- Now create the Team Player table
CREATE TABLE team_player (
    name CHAR(30),
    age INTEGER,
    employee_id INTEGER NOT NULL,
    salary INTEGER,
    jersey_number INTEGER,
    position CHAR(30),
    team_id INTEGER NOT NULL,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- Create the Coach table
CREATE TABLE coach (
    name CHAR(30),
    age INTEGER,
    employee_id INTEGER NOT NULL,
    salary INTEGER,
    coaching_role CHAR(30),
    experience_years INTEGER,
    team_id INTEGER NOT NULL,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- Create the Staff Member table
CREATE TABLE staff_member (
    name CHAR(30),
    age INTEGER,
    employee_id INTEGER NOT NULL,
    salary INTEGER,
    job_title CHAR(30),
    team_id INTEGER NOT NULL,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- Create the Game table
CREATE TABLE game (
    game_id INTEGER NOT NULL,
    date DATE,
    score CHAR(7),
    opponent CHAR(50),
    stadium_id INTEGER NOT NULL,
    PRIMARY KEY (game_id),
    FOREIGN KEY (stadium_id) REFERENCES stadium(stadium_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- Create the Log Table
CREATE TABLE log_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    log_message VARCHAR(255),
    log_date DATETIME
);

CREATE TABLE change_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    change_description VARCHAR(255),
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP
);



DELIMITER //
CREATE PROCEDURE AddPlayer(
    IN playerName CHAR(30),
    IN playerAge INT,
    IN playerEmployeeId INT,
    IN playerSalary INT,
    IN playerJerseyNumber INT,
    IN playerPosition CHAR(30),
    IN playerTeamId INT
)
BEGIN
    -- Check if the team exists
    IF EXISTS (SELECT 1 FROM team WHERE team_id = playerTeamId) THEN
        -- Insert the player
        INSERT INTO team_player (name, age, employee_id, salary, jersey_number, position, team_id)
        VALUES (playerName, playerAge, playerEmployeeId, playerSalary, playerJerseyNumber, playerPosition, playerTeamId);
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Team does not exist.';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER AfterPlayerInsert
AFTER INSERT ON team_player
FOR EACH ROW
BEGIN
    -- Log a message into a log_table
    INSERT INTO log_table (log_message, log_date)
    VALUES (CONCAT('Player ', NEW.name, ' added to Team ID: ', NEW.team_id), NOW());
END;
//
DELIMITER ;




DELIMITER //

CREATE PROCEDURE GetTeamDetailsByName(IN teamName VARCHAR(255))
BEGIN
    DECLARE teamId INT;

    -- Fetch the team_id based on the team_name
    SELECT team_id INTO teamId
    FROM team
    WHERE team_name = teamName;

    -- Check if the team exists
    IF teamId IS NULL THEN
        SELECT 'Team not found' AS error_message;
    ELSE
        -- Team details
        SELECT team_name, revenue
        FROM team
        WHERE team_id = teamId;
        -- Players in the team
        SELECT name AS player_name, position, salary
        FROM team_player
        WHERE team_id = teamId;

        -- Coaches in the team
        SELECT name AS coach_name, coaching_role, salary
        FROM coach
        WHERE team_id = teamId;

        -- Staff members in the team
        SELECT name AS staff_name, job_title, salary
        FROM staff_member
        WHERE team_id = teamId;

        -- Stadium details
        SELECT stadium_name, location, capacity
        FROM stadium
        WHERE stadium_id = (SELECT stadium_id FROM team WHERE team_id = teamId);
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE PROCEDURE AddTeam(
    IN newTeamId INT,
    IN newTeamName VARCHAR(255),
    IN newRevenue BIGINT,
    IN newStadiumId INT
)
BEGIN
    -- Check if the stadium exists
    IF EXISTS (SELECT 1 FROM stadium WHERE stadium_id = newStadiumId) THEN
        -- Insert the new team
        INSERT INTO team (team_id, team_name, revenue, stadium_id)
        VALUES (newTeamId, newTeamName, newRevenue, newStadiumId);
    ELSE
        -- Stadium does not exist, raise an error
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stadium ID does not exist.';
    END IF;
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER AfterTeamInsert
AFTER INSERT ON team
FOR EACH ROW
BEGIN
    -- Log a message into a log_table
    INSERT INTO log_table (log_message, log_date)
    VALUES (CONCAT('Team ', NEW.team_name, ' (ID: ', NEW.team_id, ') added with Stadium ID: ', NEW.stadium_id), NOW());
END;
//
DELIMITER ;




DELIMITER //

CREATE PROCEDURE GetAllTeams()
BEGIN
    SELECT 
        t.team_id, 
        t.team_name, 
        t.revenue, 
        s.stadium_name, 
        s.location
    FROM team t
    INNER JOIN stadium s ON t.stadium_id = s.stadium_id;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAllPlayers()
BEGIN
    SELECT 
        employee_id,
        name AS player_name,
        age,
        salary,
        jersey_number,
        position,
        team_id
    FROM team_player;
END //

DELIMITER ;




DELIMITER //
CREATE PROCEDURE GetPlayerDetails(IN playerName CHAR(30))
BEGIN
    SELECT tp.name AS player_name, tp.age, tp.salary, tp.jersey_number, tp.position, t.team_name
    FROM team_player tp
    JOIN team t ON tp.team_id = t.team_id
    WHERE tp.name = playerName;
END;
//
DELIMITER ;

CALL GetPlayerDetails("Enes Caglar")

DELIMITER //
CREATE PROCEDURE DeletePlayer(IN playerEmployeeId INT)
BEGIN
    DELETE FROM team_player
    WHERE employee_id = playerEmployeeId;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE GetAllCoaches()
BEGIN
    SELECT 
        employee_id,
        name AS coach_name,
        age,
        salary,
        coaching_role,
        experience_years,
        team_id
    FROM coach;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE AddCoach(
    IN coachName CHAR(30),
    IN coachAge INT,
    IN coachEmployeeId INT,
    IN coachSalary INT,
    IN coachRole CHAR(30),
    IN coachExperienceYears INT,
    IN coachTeamId INT
)
BEGIN
    -- Check if the team exists
    IF EXISTS (SELECT 1 FROM team WHERE team_id = coachTeamId) THEN
        -- Insert the coach
        INSERT INTO coach (name, age, employee_id, salary, coaching_role, experience_years, team_id)
        VALUES (coachName, coachAge, coachEmployeeId, coachSalary, coachRole, coachExperienceYears, coachTeamId);
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Team does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE DeleteCoach(IN coachEmployeeId INT)
BEGIN
    DELETE FROM coach
    WHERE employee_id = coachEmployeeId;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE SearchCoachByName(IN coachName CHAR(30))
BEGIN
    SELECT 
        employee_id,
        name AS coach_name,
        age,
        salary,
        coaching_role,
        experience_years,
        team_id
    FROM coach
    WHERE name LIKE CONCAT('%', coachName, '%');
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE GetAllStaffMembers()
BEGIN
    SELECT 
        employee_id,
        name AS staff_name,
        age,
        salary,
        job_title,
        team_id
    FROM staff_member;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddStaffMember(
    IN staffName CHAR(30),
    IN staffAge INT,
    IN staffEmployeeId INT,
    IN staffSalary INT,
    IN staffJobTitle CHAR(30),
    IN staffTeamId INT
)
BEGIN
    -- Check if the team exists
    IF EXISTS (SELECT 1 FROM team WHERE team_id = staffTeamId) THEN
        -- Insert the staff member
        INSERT INTO staff_member (name, age, employee_id, salary, job_title, team_id)
        VALUES (staffName, staffAge, staffEmployeeId, staffSalary, staffJobTitle, staffTeamId);
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Team does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE DeleteStaffMember(IN staffEmployeeId INT)
BEGIN
    DELETE FROM staff_member
    WHERE employee_id = staffEmployeeId;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE SearchStaffByName(IN staffName CHAR(30))
BEGIN
    SELECT 
        employee_id,
        name AS staff_name,
        age,
        salary,
        job_title,
        team_id
    FROM staff_member
    WHERE name LIKE CONCAT('%', staffName, '%');
END //
DELIMITER ;



DELIMITER $$

CREATE PROCEDURE GetAllStadiums()
BEGIN
    SELECT * FROM stadium;
END$$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE AddStadium(
    IN stadium_id INT,
    IN stadium_name VARCHAR(255),
    IN location VARCHAR(255),
    IN capacity INT
)
BEGIN
    INSERT INTO stadium (stadium_id, stadium_name, location, capacity)
    VALUES (stadium_id, stadium_name, location, capacity);
END$$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE getAllGames()
BEGIN
    SELECT 
        g.game_id,
        g.date,
        g.score,
        g.opponent,
        g.stadium_id,
        t.team_name AS home_team
    FROM 
        game g
    LEFT JOIN 
        (SELECT DISTINCT stadium_id, team_name FROM team) t
    ON 
        g.stadium_id = t.stadium_id;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE addGame(
    IN game_id INT,
    IN game_date DATE,
    IN game_score VARCHAR(255),
    IN game_opponent VARCHAR(255),
    IN game_stadium_id INT
)
BEGIN
    INSERT INTO game (game_id, date, score, opponent, stadium_id)
    VALUES (game_id, game_date, game_score, game_opponent, game_stadium_id);
END$$

DELIMITER ;








