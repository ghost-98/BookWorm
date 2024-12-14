from config import db


class Book(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    folder_id = db.Column(db.Integer, db.ForeignKey('library.id'), nullable=False)
    title = db.Column(db.String(50), nullable=False)
    author = db.Column(db.String(50), nullable=False)
    publisher = db.Column(db.String(50), nullable=False)
    page = db.Column(db.Integer, nullable=True)
    ISBN = db.Column(db.String(50), nullable=False)
    image = db.Column(db.String(100), nullable=True)

    # 미완

    def save_to_db(self):
        db.session.add(self)
        db.session.commit()
        return self

    def delete_from_db(self):
        db.session.delete(self)
        db.session.commit()
        return self