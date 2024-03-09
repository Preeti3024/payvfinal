from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import speech_recognition as sr



app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///payments.db'  # SQLite database file
db = SQLAlchemy(app)



class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100))
    available_amount = db.Column(db.Float)

    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'available_amount': self.available_amount
        }


class Payment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    payer = db.Column(db.String(100))
    payee = db.Column(db.String(100))
    amount = db.Column(db.Float)

    def to_dict(self):
        return {
            'id': self.id,
            'payer': self.payer,
            'payee': self.payee,
            'amount': self.amount
        }

 # Create the database tables
with app.app_context():
    db.create_all()   

def capture_speech():
  recognizer = sr.Recognizer()
  with sr.Microphone() as source:
    print("Speak your payment request!")
    audio = recognizer.listen(source)
  try:
    text = recognizer.recognize_google(audio)
    print("You said: " + text)
    return text
  except sr.UnknownValueError:
    print("Could not understand audio")
    return None
  except sr.RequestError as e:
    print("Could not request results from Google Speech Recognition service; {0}".format(e))
    return None




@app.route('/')
def index():
    return "Welcome to my Flask API!"


@app.route('/users', methods=['POST'])
def create_user():
    username = request.json.get('username')
    available_amount = request.json.get('available_amount')
    user = User(username=username, available_amount=available_amount)
    db.session.add(user)
    db.session.commit()
    return jsonify({'message': 'User created successfully'})


@app.route('/users/<username>', methods=['DELETE'])
def delete_user(username):
    user = User.query.filter_by(username=username).first()
    if user:
        db.session.delete(user)
        db.session.commit()
        return jsonify({'message': 'User deleted successfully'})
    else:
        return jsonify({'message': 'User not found'}), 404


@app.route('/users', methods=['GET'])
def get_users():
    users = User.query.all()
    return jsonify({'users': [user.to_dict() for user in users]})


@app.route('/payments', methods=['POST'])
def create_payment():
    payer = request.json.get('payer')
    payee = request.json.get('payee')
    amount = request.json.get('amount')

    speech_text = capture_speech()
    if not speech_text:
        return jsonify({'message': 'Failed to capture speech input'}), 400

    # Parse text to extract payment information (replace with your parsing logic)
    # This is a basic example, you'll need to improve it for real-world use
    
    try:
        parts = speech_text.split(" to ")
        payer = parts[0].strip()
        payee = parts[1].split(" ")[0].strip()
        amount = float(parts[1].split(" ")[1].strip())
    except:
        return jsonify({'message': 'Invalid speech format. Please say "Payer to Payee amount."'}), 400


    existing_payer = User.query.filter_by(username=payer).first()
    existing_payee = User.query.filter_by(username=payee).first()

    if existing_payer is not None and existing_payee is not None:
        if existing_payer.available_amount >= amount:
            # Update payer's balance
            existing_payer.available_amount -= amount
            db.session.commit()

            # Update payee's balance
            existing_payee.available_amount += amount
            db.session.commit()

            # Create payment record
            payment = Payment(payer=payer, payee=payee, amount=amount)
            db.session.add(payment)
            db.session.commit()

            # Fetch updated user details
            users = User.query.all()
            return jsonify({'message': 'Payment created successfully', 'users': [user.to_dict() for user in users]})
        else:
            return jsonify({'message': 'Insufficient balance for the payer'}), 400
    else:
        return jsonify({'message': 'Payer or payee does not exist'}), 400


@app.route('/payments', methods=['GET'])
def get_payments():
    payments = Payment.query.all()
    return jsonify({'payments': [payment.to_dict() for payment in payments]})


if __name__ == '__main__':
    app.run()
