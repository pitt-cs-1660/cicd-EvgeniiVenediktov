FROM python:3.11-buster as builder

WORKDIR /app

COPY pyproject.toml poetry.lock ./
ADD cc_compose ./cc_compose  
COPY entrypoint.sh .

# Install poetry only for builder stage
RUN pip install --upgrade pip && pip install poetry

# Install dependencies
RUN poetry config virtualenvs.create false \
&& poetry install --no-root --no-interaction --no-ansi

###
FROM python:3.11-buster as app

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /usr/local /usr/local

# Copy code 
COPY --from=builder /app .

EXPOSE 8000

ENTRYPOINT [ "/app/entrypoint.sh" ]

CMD [ "uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000" ]
