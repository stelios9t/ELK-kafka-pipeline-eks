# Centralized Logging Pipeline with Kafka + ELK on EKS

This project builds a production-style **real-time logging pipeline** using **Apache Kafka**, **Elasticsearch**, **Logstash**, and **Kibana** deployed on an **EKS Kubernetes cluster** using Terraform and Helm.

It simulates how real-world applications centralize logs across microservices, stream them through Kafka, and visualize them in Kibana enabling fast debugging, monitoring, and insight generation.

## The Problem

In real-world systems, applications generate tons of logs web requests, errors, security events, and more.

- Logs are scattered across multiple containers or servers.
- Debugging and monitoring becomes painfully slow and error-prone.
- Logs may get lost under high load or due to unstable pipelines.

## The Solution

This project creates a **centralized log aggregation system** using **Kafka + ELK stack** on Kubernetes.

- **Kafka** (via Strimzi) acts as a **streaming layer** that collects and buffers logs.
- **Logstash** reads logs from Kafka and pushes them into Elasticsearch.
- **Elasticsearch** stores logs in a structured and searchable format.
- **Kibana** visualizes logs in real time with dashboards and filters.

→ Kafka → Logstash → Elasticsearch → Kibana

## Tech Stack

- **AWS EKS**
- **Apache Kafka** (via Strimzi)
- **Elasticsearch**
- **Kibana**
- **Logstash**
- **Helm**
- **Terraform** for provisioning

## Project Implementation

### Log Generation

A simple Kubernetes CronJob simulates app logs and streams them to a Kafka topic (`logs-topic`).

### Kafka with Strimzi

Kafka serves as a **durable, high-speed buffer** so logs aren’t lost even if Elasticsearch is busy.

### Logstash Pipeline

Logstash reads from Kafka, parses the log data, and forwards it to Elasticsearch.

### Elasticsearch + Kibana

Elasticsearch stores logs in time-indexed documents, while Kibana provides an interactive UI for querying and visualizing logs.
