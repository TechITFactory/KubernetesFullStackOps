#!/bin/bash
echo "Executing Chaos Monkey sequence..."
echo "Simulating catastrophic datacenter failure..."
kubectl delete service redis-master -n capstone-prod > /dev/null 2>&1
echo "Database routing matrix compromised."
