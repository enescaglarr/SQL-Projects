from flask import Flask, request, jsonify, render_template
import mysql.connector
from flask_cors import CORS


app = Flask(__name__)
CORS(app)

# MySQL Connection
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="enesgs104",
    database="basketball_management"
)



@app.route('/submit-form', methods=['POST'])
def submit_form():
    data = request.get_json()
    print(data)  # Debugging: View the received data
    # Perform any backend validation or additional logic
    return jsonify({"status": "success", "message": "Form submitted successfully!"})



@app.route('/')
def home():
    return render_template('index.html')  # Ensure index.html is in the "templates" folder


@app.route('/add-player', methods=['POST'])
def add_player():
    data = request.json
    cursor = db.cursor(dictionary=True)  # Use dictionary cursor for better JSON response
    try:
        # Call the stored procedure
        cursor.callproc('AddPlayer', (
            data['name'],
            int(data['age']),
            int(data['employeeId']),
            int(data['salary']),
            int(data['jersey_number']),
            data['position'],
            int(data['team_id'])
        ))
        db.commit()

        # Fetch the latest log message (assuming the log_table is used)
        cursor.execute("SELECT log_message FROM log_table ORDER BY id DESC LIMIT 1")
        log_message = cursor.fetchone()

        return {
            "message": "Player added successfully!",
            "log": log_message['log_message'] if log_message else "No log available."
        }
    except mysql.connector.Error as e:
        db.rollback()
        return f"Error: {e.msg}", 400
    finally:
        cursor.close()



@app.route('/get-all-players', methods=['GET'])
def get_all_players():
    cursor = db.cursor(dictionary=True)
    try:
        # Call the stored procedure
        cursor.callproc('GetAllPlayers')

        # Fetch the results
        players = []
        for result in cursor.stored_results():
            players.extend(result.fetchall())

        return jsonify(players)
    except mysql.connector.Error as err:
        return f"Error: {err}", 400
    finally:
        cursor.close()


# Get Player Details
@app.route('/get-player-details/<string:player_name>', methods=['GET'])
def get_player_details(player_name):
    cursor = db.cursor(dictionary=True)
    try:
        cursor.callproc('GetPlayerDetails', [player_name])
        results = []
        for result in cursor.stored_results():
            results.extend(result.fetchall())
        if len(results) == 0:
            return jsonify({"error": "Player not found"}), 404
        return jsonify(results[0])  # Return the first (and only) player details
    except mysql.connector.Error as err:
        return f"Error: {err}", 400
    finally:
        cursor.close()

@app.route('/get-all-teams', methods=['GET'])
def get_all_teams():
    cursor = db.cursor(dictionary=True)
    try:
        # Call the stored procedure
        cursor.callproc('GetAllTeams')

        # Fetch the results
        teams = []
        for result in cursor.stored_results():
            teams.extend(result.fetchall())

        return jsonify(teams)
    except mysql.connector.Error as err:
        return f"Error: {err}", 400
    finally:
        cursor.close()

# Delete Player
@app.route('/delete-player/<int:employee_id>', methods=['DELETE'])
def delete_player(employee_id):
    cursor = db.cursor()
    try:
        cursor.callproc('DeletePlayer', [employee_id])
        db.commit()
        return "Player deleted successfully!"
    except mysql.connector.Error as e:
        db.rollback()
        return f"Error: {e}", 400
    finally:
        cursor.close()
        





@app.route('/get-team-details/<string:team_name>', methods=['GET'])
def get_team_details_by_name(team_name):
    cursor = db.cursor(dictionary=True)
    try:
        # Call the stored procedure
        cursor.callproc('GetTeamDetailsByName', [team_name])

        # Fetch the results of the procedure
        results = []
        for result in cursor.stored_results():
            results.append(result.fetchall())

        # If no team is found, the first result will contain the error message
        if 'error_message' in results[0][0]:
            return jsonify({"error": results[0][0]['error_message']}), 404

        # Extract details from results
        team_details = results[0][0]  # First result set: Team details
        players = results[1]          # Second result set: Players
        coaches = results[2]          # Third result set: Coaches
        staff = results[3]            # Fourth result set: Staff
           # Handle stadium details (single result)
        stadium = results[4][0] if len(results[4]) > 0 else None          # Fifth result set: Stadium

        return jsonify({
            "team": team_details,
            "players": players,
            "coaches": coaches,
            "staff": staff,
            "stadium": stadium
        })
    except mysql.connector.Error as err:
        return f"Error: {err}", 400
    finally:
        cursor.close()



@app.route('/add-team', methods=['POST'])
def add_team():
    data = request.json
    cursor = db.cursor(dictionary=True)
    try:
        cursor.callproc('AddTeam', (
            int(data['team_id']),
            data['team_name'],
            int(data['revenue']),
            int(data['stadium_id'])
        ))
        db.commit()

        # Fetch the latest log message
        cursor.execute("SELECT log_message FROM log_table ORDER BY id DESC LIMIT 1")
        log_message = cursor.fetchone()

        return {
            "message": "Team added successfully!",
            "log": log_message['log_message'] if log_message else "No log available."
        }
    except mysql.connector.Error as e:
        db.rollback()
        return f"Error: {e.msg}", 400
    finally:
        cursor.close()


@app.route('/get-all-coaches', methods=['GET'])
def get_all_coaches():
    cursor = db.cursor(dictionary=True)
    try:
        cursor.callproc('GetAllCoaches')  # Replace with your stored procedure name
        coaches = []
        for result in cursor.stored_results():
            coaches.extend(result.fetchall())
        return jsonify(coaches)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()



@app.route('/add-coach', methods=['POST'])
def add_coach():
    data = request.json
    cursor = db.cursor()
    try:
        cursor.callproc('AddCoach', [
            data['name'],
            data['age'],
            data['employee_id'],
            data['salary'],
            data['role'],
            data['experience_years'],
            data['team_id']
        ])
        db.commit()
        return "Coach added successfully!"
    except mysql.connector.Error as err:
        db.rollback()
        return f"Error: {err.msg}", 400
    finally:
        cursor.close()


@app.route('/delete-coach/<int:employee_id>', methods=['DELETE'])
def delete_coach(employee_id):
    cursor = db.cursor()
    try:
        cursor.callproc('DeleteCoach', [employee_id])
        db.commit()
        return "Coach deleted successfully!"
    except mysql.connector.Error as err:
        db.rollback()
        return f"Error: {err}", 400
    finally:
        cursor.close()


@app.route('/search-coach/<string:coach_name>', methods=['GET'])
def search_coach_by_name(coach_name):
    cursor = db.cursor(dictionary=True)
    try:
        cursor.callproc('SearchCoachByName', [coach_name])
        coaches = []
        for result in cursor.stored_results():
            coaches.extend(result.fetchall())
        return jsonify(coaches)
    except mysql.connector.Error as err:
        return f"Error: {err}", 400
    finally:
        cursor.close()


@app.route('/get-all-staff', methods=['GET'])
def get_all_staff():
    cursor = db.cursor(dictionary=True)
    try:
        # Call the correct stored procedure
        cursor.callproc('GetAllStaffMembers')
        
        # Fetch the results
        staff = []
        for result in cursor.stored_results():
            staff.extend(result.fetchall())
        
        print('Fetched staff:', staff)  # Debugging log
        return jsonify(staff)
    except Exception as e:
        print('Error fetching staff:', str(e))  # Debugging log
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()



@app.route('/add-staff', methods=['POST'])
def add_staff():
    data = request.json
    cursor = db.cursor()
    try:
        cursor.callproc('AddStaffMember', [
            data['name'],
            data['age'],
            data['employee_id'],
            data['salary'],
            data['job_title'],
            data['team_id']
        ])
        db.commit()
        return "Staff member added successfully!"
    except mysql.connector.Error as err:
        db.rollback()
        return f"Error: {err.msg}", 400
    finally:
        cursor.close()


@app.route('/delete-staff/<int:employee_id>', methods=['DELETE'])
def delete_staff(employee_id):
    cursor = db.cursor()
    try:
        cursor.callproc('DeleteStaffMember', [employee_id])
        db.commit()
        return "Staff member deleted successfully!"
    except mysql.connector.Error as err:
        db.rollback()
        return f"Error: {err}", 400
    finally:
        cursor.close()


@app.route('/search-staff/<string:staff_name>', methods=['GET'])
def search_staff_by_name(staff_name):
    cursor = db.cursor(dictionary=True)
    try:
        cursor.callproc('SearchStaffByName', [staff_name])
        staff = []
        for result in cursor.stored_results():
            staff.extend(result.fetchall())
        return jsonify(staff)
    except mysql.connector.Error as err:
        return f"Error: {err}", 400
    finally:
        cursor.close()
        
@app.route('/get-all-stadiums', methods=['GET'])
def get_all_stadiums():
    cursor = db.cursor(dictionary=True)
    try:
        # Call the stored procedure
        cursor.callproc('GetAllStadiums')

        # Fetch the results
        stadiums = []
        for result in cursor.stored_results():
            stadiums.extend(result.fetchall())

        return jsonify(stadiums), 200
    except mysql.connector.Error as err:
        return jsonify({"error": f"Error fetching stadiums: {err}"}), 400
    finally:
        cursor.close()


@app.route('/add-stadium', methods=['POST'])
def add_stadium():
    data = request.json
    print(data)  # Log the data
    cursor = db.cursor()
    try:
        cursor.callproc('AddStadium', [
            data['stadium_id'],
            data['stadium_name'],
            data['location'],
            data['capacity']
        ])
        db.commit()
        return "Stadium added successfully!", 200
    except mysql.connector.Error as err:
        db.rollback()
        return f"Error: {err.msg}", 400
    finally:
        cursor.close()



@app.route('/get-all-games', methods=['GET'])
def get_all_games():
    cursor = db.cursor(dictionary=True)
    try:
        # Call the stored procedure
        cursor.callproc('getAllGames')

        # Fetch the results
        games = []
        for result in cursor.stored_results():
            games.extend(result.fetchall())

        return jsonify(games), 200
    except mysql.connector.Error as err:
        return jsonify({"error": f"Error fetching games: {err}"}), 400
    finally:
        cursor.close()


        
@app.route('/add-game', methods=['POST'])
def add_game():
    data = request.json
    cursor = db.cursor()
    try:
        # Validate input
        if not all(key in data for key in ('game_id', 'date', 'score', 'opponent', 'stadium_id')):
            return jsonify({"error": "All fields (game_id, date, score, opponent, stadium_id) are required"}), 400

        # Call the stored procedure
        cursor.callproc('addGame', [
            data['game_id'],
            data['date'],
            data['score'],
            data['opponent'],
            data['stadium_id']
        ])
        db.commit()
        return jsonify({"message": "Game added successfully"}), 201
    except mysql.connector.Error as err:
        return jsonify({"error": f"Error adding game: {err}"}), 400
    finally:
        cursor.close()




if __name__ == '__main__':
    app.run(debug=True)
