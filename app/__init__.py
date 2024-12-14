from flask import Flask
from flask_cors import CORS
from flask_migrate import Migrate

from config import db, jwt

from .blueprints.auth import auth_bp
from .blueprints.book import book_bp
from .blueprints.library import library_bp


def create_app():
    app = Flask(__name__)

    # flutter의 요청 허용
    CORS(app)

    # flask 앱의 설정 가져와서 적용
    app.config.from_object('config.Config')

    # 확장 초기화
    db.init_app(app)
    jwt.init_app(app)
    migrate = Migrate(app, db)

    # Blueprint 등록
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(book_bp, url_prefix='/book')
    app.register_blueprint(library_bp, url_prefix='/library')

    return app
