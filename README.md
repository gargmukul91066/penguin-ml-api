# 🐧 Penguin ML API — End-to-End (ML → FastAPI → Docker → AWS ECR/ECS)

RandomForest model trained on the **Palmer Penguins** dataset, served via **FastAPI** with a simple HTML UI, containerized with **Docker**, pushed to **AWS ECR**, and deployed on **AWS ECS Fargate** behind a **public IP on port 8000**.

**Deployed Live:**

```
http://34.226.204.228:8000/
http://34.226.204.228:8000/ui
```

---

## Table of Contents

- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
  - [Train](#train)
  - [Evaluate (optional)](#evaluate-optional)
  - [Run API (no Docker)](#run-api-no-docker)
- [API Endpoints](#api-endpoints)
- [Docker](#docker)
- [Push to ECR](#push-to-ecr)
- [Deploy to ECS Fargate](#deploy-to-ecs-fargate)
- [Update an Existing Service](#update-an-existing-service)
- [Troubleshooting](#troubleshooting)
- [Costs & Cleanup](#costs--cleanup)
- [Security & Hardening (Later)](#security--hardening-later)
- [Makefile-Style Cheat Sheet](#makefilestyle-cheat-sheet)

---

## Architecture

<img width="1187" height="75" alt="image" src="https://github.com/user-attachments/assets/1b967898-a50f-4509-adec-7ffdcaa9458b" />


**Flow:**  
**Local**: Train → `model.pkl` → build Docker → push to **ECR**  
**Cloud**: **ECS Fargate** pulls image → runs container → **Public IP:8000** → User hits `/ui` or `/predict`.

---

## Tech Stack

- **Model**: scikit-learn RandomForest
- **Serving**: FastAPI + Uvicorn
- **Container**: Docker
- **AWS**: ECR (registry) + ECS Fargate (orchestration)
- **Language**: Python 3.11

---

## Project Structure

```
penguin_ml_end_to_end/
├── artifacts/
│   └── model.pkl
├── data/
│   ├── processed/
│   │   └── penguins_clean.csv
│   └── raw/
│       └── penguins.csv
├── notebooks/
│   └── explore_penguins.ipynb
├── src/
│   ├── app.py                      # FastAPI app: /, /health, /predict, /ui
│   └── models/
│       ├── __init__.py
│       ├── data_loader.py
│       ├── preprocess.py
│       ├── train.py               # trains RandomForest → artifacts/model.pkl
│       ├── evaluate.py            # prints accuracy + report
│       └── predict.py             # loads model.pkl and predicts
├── tests/
│   ├── test_app.py
│   └── test_data_pipeline.py
├── Dockerfile
├── requirements.txt
└── .dockerignore
```

**`requirements.txt`:**

```
pandas
numpy
scikit-learn
fastapi
uvicorn[standard]
python-multipart
mlflow
```

**`.dockerignore`:**

```
__pycache__/
*.pyc
*.pyo
*.pyd
*.log
.env
.venv/
notebooks/
data/
tests/
.git/
.gitignore
```

---

## Prerequisites

- Docker Desktop installed & running
- AWS CLI configured:

```
aws --version
aws configure  # region: us-east-1, output: json
```

**Your AWS deployment values:**

| Component        | Value                           |
| ---------------- | ------------------------------- |
| Account ID       | `439391123211`                  |
| Region           | `us-east-1`                     |
| ECR Repo         | `penguin-ml-end-to-end`         |
| ECS Cluster      | `penguin-ml-cluster-new`        |
| Task Definition  | `penguin-ml-task:1`             |
| Container Name   | `penguin-ml-container`          |
| Port Mapping     | `8000 -> 8000`                  |
| Subnets          | Public (1a, 1d)                 |
| Security Group   | Inbound TCP 8000 from 0.0.0.0/0 |
| Assign Public IP | ENABLED                         |
| Execution Role   | `ecsTaskExecutionRole`          |

---

## Local Development

### Train

```
python -m src.models.train
# => artifacts/model.pkl
```

### Evaluate (optional)

```
python -m src.models.evaluate
```

### Run API (no Docker)

```
uvicorn src.app:app --host 0.0.0.0 --port 8000
# http://localhost:8000/ui
```

---

## API Endpoints

| Method   | Route      | Description               |
| -------- | ---------- | ------------------------- |
| GET      | `/`        | Basic status message      |
| GET      | `/health`  | Health check              |
| POST     | `/predict` | Predict species (JSON)    |
| GET/POST | `/ui`      | Web form for manual input |

Example JSON:

```
{
  "bill_length_mm": 43.2,
  "bill_depth_mm": 18.7,
  "flipper_length_mm": 195,
  "body_mass_g": 4200
}
```

---

## Docker

```
docker build -t penguin-ml-end-to-end:latest .
docker run --rm -p 8000:8000 penguin-ml-end-to-end:latest
```

---

## Push to ECR

```
AWS_REGION=us-east-1
AWS_ACCT=439391123211
REPO=penguin-ml-end-to-end
ECR_URI=$AWS_ACCT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCT.dkr.ecr.$AWS_REGION.amazonaws.com

docker tag $REPO:latest $ECR_URI:latest
docker push $ECR_URI:latest
```

---

## Deploy to ECS Fargate

- Cluster: `penguin-ml-cluster-new`
- Task Definition: `penguin-ml-task`
- Image: `$ECR_URI:latest`
- Container Port: `8000`
- Public Subnets
- Security Group: allow TCP 8000 from anywhere
- Assign Public IP: ENABLED

Test:

```
http://34.226.204.228:8000
http://34.226.204.228:8000/ui
```

---

## Update an Existing Service

```
docker build -t $REPO .
docker tag $REPO:latest $ECR_URI:latest
docker push $ECR_URI:latest

aws ecs update-service   --cluster penguin-ml-cluster-new   --service <YOUR_SERVICE_NAME>   --force-new-deployment   --region $AWS_REGION
```

---

## Troubleshooting

| Problem                  | Fix                                            |
| ------------------------ | ---------------------------------------------- |
| Can't access UI          | Ensure SG allows TCP 8000 & Public IP enabled  |
| ECS restarts             | Missing packages (`uvicorn`), bad imports      |
| CannotPullContainerError | Push image again & force deploy                |
| Model missing            | Ensure Dockerfile copies `artifacts/model.pkl` |

---

## Costs & Cleanup

- Stop billing: set desired tasks to **0** or delete service.
- Optionally delete ECR images and Cluster.

---

## Makefile-Style Cheat Sheet

```
AWS_REGION=us-east-1
AWS_ACCT=439391123211
REPO=penguin-ml-end-to-end
ECR_URI=$AWS_ACCT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO

python -m src.models.train
uvicorn src.app:app --host 0.0.0.0 --port 8000
docker build -t $REPO .
docker run --rm -p 8000:8000 $REPO
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCT.dkr.ecr.$AWS_REGION.amazonaws.com
docker tag $REPO:latest $ECR_URI:latest
docker push $ECR_URI:latest
aws ecs update-service --cluster penguin-ml-cluster-new --service <YOUR_SERVICE_NAME> --force-new-deployment --region $AWS_REGION
```

---

## UI Preview

<img width="1919" height="1198" alt="image" src="https://github.com/user-attachments/assets/67fb2e3e-489d-4ed2-ab7b-60a45e763245" />

