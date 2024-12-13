from app import create_app

app = create_app()

if __name__ == "__main__":
    # Flask 서버를 모든 네트워크 인터페이스(IP 주소)에서 접근 가능하게
    app.run(host='0.0.0.0', port=5000, debug=True)
