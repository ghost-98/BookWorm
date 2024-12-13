from config import db


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), unique=True, nullable=False)
    email = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(50), nullable=False)
    name = db.Column(db.String(30), nullable=False)
    phone_number = db.Column(db.String(20), nullable=False)
    birth_day = db.Column(db.Date, nullable=False)
    gender = db.Column(db.String(10), nullable=False)

    # 관계 정의
    libraries = db.relationship('Library', backref='user', lazy=True)

    def save_to_db(self):
        db.session.add(self)
        db.session.commit()
        return self
