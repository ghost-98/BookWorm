from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.models.library import Library
from config import db

library_bp = Blueprint('library', __name__)


# 서재 생성 API
@library_bp.route('/', methods=['POST'])
@jwt_required()
def make_library():
    data = request.get_json()

    user_id = get_jwt_identity()
    name = data.get("name")
    desc = data.get("desc")

    # 사용자의 서재중에서만 이름중복 찾기
    if Library.query.filter_by(name=name).first():
        return jsonify({'message': '동일한 서재명이 존재합니다'}), 409

    new_library = Library(user_id=user_id, name=name, desc=desc)
    Library.save_to_db(new_library)

    return jsonify({"message": "서재 생성이 완료되었습니다"}), 201


# 전체 서재 조회 API
# jwt로 요청 유저의 id값 알 수 있는데 /<int:user_id> 써야하나 -> jwt가 우선됨. 보안상
@library_bp.route('/<int:user_id>', methods=['GET'])
@jwt_required()
def get_library():
    user_id = get_jwt_identity()

    libraries = Library.query.filter_by(user_id=user_id).all()
    return jsonify({"libraries": libraries}), 200


# 서재 수정 API
@library_bp.route('/<int:folder_id>', methods=['PUT'])
@jwt_required()
def update_library(folder_id):
    data = request.get_json()
    user_id = get_jwt_identity()

    name = data.get("name")
    desc = data.get("desc")

    library = Library.query.filter_by(id=folder_id, user_id=user_id).first()

    if not library:
        return jsonify({'error': '해당 서재를 찾을 수 없습니다'}), 404

    library.name = name
    library.desc = desc
    Library.save_to_db(library)

    # 수정 시 값 반환하면 200, 반환안하고 성공만 알릴시 204
    return jsonify({'message': '서재 정보 수정이 완료되었습니다'}), 204


# 서재 삭제 API
# delete의 url 형식?
@library_bp.route('/<id>', methods=['delete'])
@jwt_required()
def delete_library():
    user_id = get_jwt_identity()
    library_id = request.args.get("id")

    library = Library.query.filter_by(id=library_id, user_id=user_id).first()

    if not library:
        return jsonify({'error': '해당 서재를 찾을 수 없습니다'}), 404

    Library.delete_from_db(library)
    return jsonify({'message': '서재 삭제가 완료되었습니다'}), 204
