#!/bin/bash
echo "Streaming mock application logs for tracing..."
for i in {1..5}; do
  echo "[INFO] Transaction $i completed successfully."
  sleep 1
done
echo "[ERROR] Database timeout on transaction 6! TraceID: 88f2x"
