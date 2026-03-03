# 🐧 Penguin ML API — End-to-End ML Deployment

An end-to-end machine learning project that trains a classification model and deploys it as a production-ready API using **FastAPI + Docker + Cloud Deployment (Render)**.

---

## 🚀 Live Demo

- **Web UI:** https://penguin-ml-api.onrender.com/ui  
- **API Root:** https://penguin-ml-api.onrender.com  

> ⚠️ Hosted on Render free tier. First request may take ~30 seconds if idle.

---

## 📌 Project Overview

This project demonstrates:

- Data preprocessing & feature engineering
- Model training (RandomForest - scikit-learn)
- Model serialization (`model.pkl`)
- REST API development with FastAPI
- Docker containerization
- Cloud deployment (Render)
- Automated redeployment via Git push

It simulates a real-world ML-to-production workflow.

---

## 🏗 Architecture

```
Dataset → Preprocessing → Train Model → model.pkl
          ↓
      FastAPI App
          ↓
      Docker Image
          ↓
      Cloud Deployment (Render)
          ↓
      Public API + Web UI
```

---

## 🛠 Tech Stack

- **Language:** Python 3.11
- **ML Model:** scikit-learn (RandomForest)
- **API Framework:** FastAPI
- **Server:** Uvicorn
- **Containerization:** Docker
- **Deployment:** Render (Cloud PaaS)
- **Testing:** Pytest

---

## 📂 Project Structure

```
penguin-ml-api/
│
├── artifacts/
│   └── model.pkl
│
├── src/
│   ├── app.py
│   └── models/
│       ├── train.py
│       ├── preprocess.py
│       └── predict.py
│
├── tests/
│
├── Dockerfile
├── requirements.txt
└── README.md
```

---

## 🧠 API Endpoints

| Method | Route      | Description |
|--------|-----------|------------|
| GET    | `/`       | API status |
| GET    | `/health` | Health check |
| POST   | `/predict`| Predict species (JSON) |
| GET/POST | `/ui`  | Web interface |

---

### 📥 Example JSON Request

```json
{
  "bill_length_mm": 43.2,
  "bill_depth_mm": 18.7,
  "flipper_length_mm": 195,
  "body_mass_g": 4200
}
```

---

## 🖥 Run Locally

### 1️⃣ Install dependencies

```
pip install -r requirements.txt
```

### 2️⃣ Run API

```
uvicorn src.app:app --host 0.0.0.0 --port 8000
```

Open:
```
http://localhost:8000/ui
```

---

## 🐳 Run with Docker

### Build image

```
docker build -t penguin-ml-api .
```

### Run container

```
docker run -p 8000:8000 penguin-ml-api
```

---

## 🔄 Deployment

This project is deployed using:

- GitHub (source control)
- Docker (container build)
- Render (automatic deployment from main branch)

Every push to `main` triggers a new deployment.

---

## 🧪 Testing

```
pytest
```

---

## 📈 Why This Project Matters

This project demonstrates the full ML lifecycle:

✔ Model training  
✔ API development  
✔ Containerization  
✔ Cloud deployment  
✔ Public live service  

It reflects practical backend + ML engineering skills beyond notebooks.

---

## 👨‍💻 Author

Built as part of a hands-on ML deployment portfolio project.
