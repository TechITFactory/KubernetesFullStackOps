# Minimal image for Part 0 — same idea as building an image Kubernetes will run later
FROM alpine:3.19
RUN adduser -D -u 1000 appuser && \
    echo "K8sOps Part 0 Docker lab" > /etc/lab-message.txt
USER appuser
WORKDIR /home/appuser
CMD ["cat", "/etc/lab-message.txt"]
