FROM ghcr.io/cirruslabs/flutter:stable AS build


ARG BACKEND_API_URL
ARG CLOUDINARY_CLOUD_NAME
ARG CLOUDINARY_UPLOAD_PRESET
ARG WS_URL

WORKDIR /app
COPY . .


RUN flutter pub get
RUN flutter build web --release \
                    --dart-define=BACKEND_API_URL=${BACKEND_API_URL} \
                    --dart-define=CLOUDINARY_CLOUD_NAME=${CLOUDINARY_CLOUD_NAME} \
                    --dart-define=CLOUDINARY_UPLOAD_PRESET=${CLOUDINARY_UPLOAD_PRESET} \
                    --dart-define=WS_URL=${WS_URL} 


FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]