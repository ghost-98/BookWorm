from flask import Flask
from config import db, jwt

from .blueprints.auth import auth_bp
from .blueprints.book import book_bp


def create_app():
    app = Flask(__name__)

    # flask 앱의 설정 가져와서 적용
    app.config.from_object('config.Config')

    # 확장 초기화
    db.init_app(app)
    jwt.init_app(app)

    # Blueprint 등록
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(book_bp, url_prefix='/book')

    return app
