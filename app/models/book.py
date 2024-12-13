from config import db


class Book(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    folder_id = db.Column(db.Integer, db.ForeignKey('folder.id'), nullable=False)
    title = db.Column(db.String(80), nullable=False)

    # 미완