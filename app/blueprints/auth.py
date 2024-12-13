from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token
from app.models.user import User

from datetime import datetime

# 블루프린트로 라우팅
auth_bp = Blueprint('auth', __name__)


# 회원가입 API
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = generate_password_hash(data.get('password'))
    email = data.get('email')
    name = data.get('name')
    phone_number = data.get('phone_number')
    birth_day = data.get('birth_day')
    gender = data.get('gender')

    # 문자열을 datetime.date로 변환
    try:
        birth_day = datetime.strptime(birth_day, '%Y-%m-%d').date()
    except ValueError:
        return jsonify({"message": "유효하지 않은 생년월일 형식입니다. YYYY-MM-DD 형식을 사용하세요."}), 400

    # username, email, phone_number에 대한 중복 확인
    # 모듈화 통한 리팩토리 가능
    if User.query.filter_by(username=username).first():
        return jsonify({'message': '동일한 ID가 존재합니다'}), 409
    if User.query.filter_by(email=email).first():
        return jsonify({'message': '동일한 email이 존재합니다'}), 409
    if User.query.filter_by(phone_number=phone_number).first():
        return jsonify({'message': '동일한 전화번호가 존재합니다'}), 409

    new_user = User(
        username=username,
        password=password,
        email=email,
        name=name,
        phone_number=phone_number,
        birth_day=birth_day,
        gender=gender
    )

    # db에 사용자 정보 커밋
    User.save_to_db(new_user)

    return jsonify({"message": "회원가입이 성공적으로 완료되었습니다"}), 201


# 로그인 API
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = User.query.filter_by(username=username).first()

    if not user or not check_password_hash(user.password, password):
        return jsonify({"message": "유효하지 않은 ID나 비밀번호입니다"}), 401

    access_token = create_access_token(identity=str(user.id))
    return jsonify(access_token=access_token), 200
