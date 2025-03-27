// import axios from 'axios';
// // import router from '@/router';

// // Axios 인스턴스 생성
// const instance = axios.create({
//   baseURL: '/api', // 프록시 경로와 일치
//   headers: {
//     'Content-Type': 'application/json', // JSON 데이터를 처리하기 위한 기본 헤더
//   },
// });
// export default instance; // 인터셉터가 적용된 Axios 인스턴스

import axios from 'axios';

// .env에서 API 주소 가져오기 (기본값: localhost)
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';

// Axios 인스턴스 생성
const instance = axios.create({
    baseURL: API_BASE_URL, // .env에서 설정된 API 주소 사용
    headers: {
        'Content-Type': 'application/json', // JSON 데이터를 처리하기 위한 기본 헤더
    },

});

export default instance; // 인터셉터가 적용된 Axios 인스턴스
