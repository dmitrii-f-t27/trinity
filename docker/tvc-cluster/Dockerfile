FROM alpine:latest
RUN apk add --no-cache python3
COPY server.py /server.py
EXPOSE 8080
CMD ["python3", "/server.py"]
