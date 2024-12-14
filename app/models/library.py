from config import db


class Library(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    name = db.Column(db.String(20), nullable=False)
    desc = db.Column(db.String(50), nullable=True)

    # 관계 설정
    # books = db.relationship('Book', backref='library', lazy=True)

    def save_to_db(self):
        db.session.add(self)
        db.session.commit()
        return self

    def delete_from_db(self):
        db.session.delete(self)
        db.session.commit()
        return self

    def to_dict(self):
        """객체를 딕셔너리로 변환"""
        return {
            "id": self.id,
            "user_id": self.user_id,
            "name": self.name,
            "desc": self.desc,
        }
