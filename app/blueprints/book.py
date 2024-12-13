from flask import Blueprint, request, jsonify
from config import API_KEY, NATIONAL_LIBRARY_API_URL
import requests

book_bp = Blueprint('book', __name__)

# 두 검색 API 통합 하기

# 도서 검색 API (제목)
@book_bp.route('/search_title', methods=['GET'])
def search_title():
    # 쿼리에서 매개변수 가져옴(GET) / 공백이 들어간 검색어 예외사항 고려
    title = request.args.get('keyword', '').strip()
    if not title:
        return jsonify({"error": "검색어가 누락되었습니다"}), 400

    params = {
        "cert_key": API_KEY,
        "result_style": "json",
        "page_no": 1,
        "page_size": 10,
        "title": title,
        # 필요한 추가 매개변수
    }

    response = requests.get(NATIONAL_LIBRARY_API_URL, params=params)
    if response.status_code != 200:
        return jsonify({"error": "검색하는데 실패했습니다"}), 500

    try:
        data = response.json()
        return jsonify(data), 200
    except ValueError:
        return jsonify({"error": "Invalid response from National Library API"}), 500


# 도서 검색 API (ISBN)
@book_bp.route('/search_isbn', methods=['GET'])
def search_isbn():
    isbn = request.args.get('isbn', '').strip()
    if not isbn:
        return jsonify({"error": "ISBN값이 누락되었습니다"}), 400

    params = {
        "cert_key": API_KEY,
        "result_style": "json",
        "isbn": isbn,
        # 필요한 추가 매개변수
    }

    response = requests.get(NATIONAL_LIBRARY_API_URL, params=params)
    if response.status_code != 200:
        return jsonify({"error": "검색하는데 실패했습니다"}), 500


# 서재에 도서 추가 API
@book_bp.route('/add_library', methods=['POST'])
def add_library():
    title = request.args.get('title', '').strip()

# 서재의 모든 도서 조회 API

# 서재에서 도서 삭제 API
