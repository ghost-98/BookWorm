from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.models.library import Library
from app.models.book import Book

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
@library_bp.route('/', methods=['GET'])
@jwt_required()
def get_library():
    user_id = get_jwt_identity()

    libraries = Library.query.filter_by(user_id=user_id).all()
    library_list = [library.to_dict() for library in libraries]

    return jsonify({"libraries": library_list}), 200


# 서재 수정 API
@library_bp.route('/<int:library_id>', methods=['PUT'])
@jwt_required()
def update_library(library_id):
    data = request.get_json()
    user_id = get_jwt_identity()

    name = data.get("name")
    desc = data.get("desc")

    library = Library.query.filter_by(id=library_id, user_id=user_id).first()

    if not library:
        return jsonify({'error': '해당 서재를 찾을 수 없습니다'}), 404

    library.name = name
    library.desc = desc
    Library.save_to_db(library)

    # 수정 시 값 반환하면 200, 반환안하고 성공만 알릴시 204
    return jsonify({'message': '서재 정보 수정이 완료되었습니다'}), 204


# 서재 삭제 API
# delete의 url 형식?
@library_bp.route('/<int:library_id>', methods=['DELETE'])
@jwt_required()
def delete_library(library_id):
    user_id = get_jwt_identity()

    library = Library.query.filter_by(id=library_id, user_id=user_id).first()

    if not library:
        return jsonify({'error': '해당 서재를 찾을 수 없습니다'}), 404

    Library.delete_from_db(library)
    return jsonify({'message': '서재 삭제가 완료되었습니다'}), 204


# 서재에 도서 추가 API
@library_bp.route('/add_book', methods=['POST'])
@jwt_required()
def add_library():
    user_id = get_jwt_identity()
    data = request.json  # JSON 데이터 받기
    library_id = data.get('library_id')
    title = data.get('title')
    author = data.get('author')
    publisher = data.get('publisher')
    page = data.get('page')
    ISBN = data.get('ISBN')
    image = data.get('image')

    # 서재 확인
    library = Library.query.filter_by(id=library_id, user_id=user_id).first()
    if not library:
        return jsonify({"error": "유효하지 않은 서재입니다."}), 400

    # 새로운 도서 객체 생성 및 저장
    new_book = Book(
        folder_id=library_id,
        title=title,
        author=author,
        publisher=publisher,
        page=page,
        ISBN=ISBN,
        image=image
    )
    new_book.save_to_db()

    return jsonify({"message": "도서가 서재에 추가되었습니다."}), 201


# 서재의 모든 도서 조회 API
@library_bp.route('/<int:library_id>', methods=['GET'])
@jwt_required()
def get_books_in_library(library_id):
    user_id = get_jwt_identity()

    # 서재 확인
    library = Library.query.filter_by(id=library_id, user_id=user_id).first()
    if not library:
        return jsonify({"error": "유효하지 않은 서재입니다."}), 400

    # 해당 서재에 포함된 책 조회
    books = Book.query.filter_by(folder_id=library_id).all()
    books_data = [
        {
            "id": book.id,
            "title": book.title,
            "author": book.author,
            "publisher": book.publisher,
            "page": book.page,
            "ISBN": book.ISBN,
            "image": book.image,
        }
        for book in books
    ]

    return jsonify({"books": books_data}), 200


# 서재에서 책 삭제 API
@library_bp.route('/<int:library_id>/book/<int:book_id>', methods=['DELETE'])
@jwt_required()
def delete_book_from_library(library_id, book_id):
    user_id = get_jwt_identity()

    # 서재 확인
    library = Library.query.filter_by(id=library_id, user_id=user_id).first()
    if not library:
        return jsonify({"error": "유효하지 않은 서재입니다."}), 400

    # 책 확인
    book = Book.query.filter_by(id=book_id, folder_id=library_id).first()
    if not book:
        return jsonify({"error": "책을 찾을 수 없습니다."}), 404

    # 책 삭제
    Library.delete_from_db(book)

    return jsonify({"message": "책이 삭제되었습니다."}), 204
