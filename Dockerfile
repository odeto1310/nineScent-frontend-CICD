# 1. Node.js를 사용하여 Vue.js 빌드
FROM node:18-alpine AS build

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 환경 변수 설정 (메모리 문제 방지)
ENV NODE_OPTIONS="--max-old-space-size=2048"

# 4. package.json과 package-lock.json 복사 후 의존성 설치
COPY package.json package-lock.json ./
RUN npm ci --prefer-offline --no-audit

# 5. 모든 Vue.js 코드 복사 후 빌드 실행
COPY . .
RUN npm run build

# 6. Nginx로 정적 파일 제공
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# 7. 컨테이너 실행 시 Nginx 시작
CMD ["nginx", "-g", "daemon off;"]

# 8. 컨테이너가 노출할 포트
EXPOSE 80