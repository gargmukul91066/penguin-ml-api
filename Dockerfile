# 1. Base image
FROM python:3.11-bullseye

# 2. Set working directory
WORKDIR /app

# 3. Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy source code
COPY src ./src

# 5. Copy trained model artifact
COPY artifacts/model.pkl ./artifacts/model.pkl

# 6. Expose app port
EXPOSE 8000

# 7. Run FastAPI app with uvicorn
CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000"]
