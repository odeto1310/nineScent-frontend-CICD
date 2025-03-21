#1. node.js 이용 vue.js 빌드
FROM node:18-alpine AS build

#2. 작업 디렉토리 설정
WORKDIR /app

# 3. package.json과 package-lock.json 복사 후 의존성 설치
COPY package.json package-lock.json ./
RUN npm install

# 4. 모든 Vue.js 코드 복사 후 빌드 실행
COPY . .
RUN npm run build

# 5. Nginx로 정적 파일 제공
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# 6. 컨테이너 실행 시 Nginx 시작
CMD ["nginx", "-g", "daemon off;"]

# 7. 컨테이너가 노출할 포트
EXPOSE 80
