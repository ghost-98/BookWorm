# 환경 변수로 설정하는 이유는 민감한 데이터를 코드에 직접 포함하지 않기 위해 (보안 문제)
# .env 파일을 사용해 환경 변수를 설정할 수도 있음

from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager

import os

# DB
db = SQLAlchemy()

# JWT
jwt = JWTManager()

# 국립중앙도서관 API 기본 설정
NATIONAL_LIBRARY_API_URL = "https://www.nl.go.kr/seoji/SearchApi.do"
API_KEY = "07ff4cf12b7e16a21a51c79cd644b51a855b53a43baace93eb3983d9d8556c09"


class Config:
    # SECRET_KEY = os.environ.get('SECRET_KEY', 'your_secret_key')
    SQLALCHEMY_DATABASE_URI = 'sqlite:///app.db'
    # SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'yuchan')
