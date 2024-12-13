from config import db


class Book(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    folder_id = db.Column(db.Integer, db.ForeignKey('library.id'), nullable=False)
    title = db.Column(db.String(80), nullable=False)

    # 미완

    def save_to_db(self):
        db.session.add(self)
        db.session.commit()
        return self