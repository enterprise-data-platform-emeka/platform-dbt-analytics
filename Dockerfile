# ---- build stage ----
# Install Python dependencies into a clean layer so the final image doesn't
# carry pip caches or build tools.
FROM python:3.11-slim AS builder

WORKDIR /build

# Copy only the requirements file first so Docker cache reuses this layer
# on subsequent builds when only the dbt project files have changed.
COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt


# ---- runtime stage ----
FROM python:3.11-slim

# Install the compiled packages from the build stage.
COPY --from=builder /install /usr/local

WORKDIR /usr/app/dbt

# Create a non-root user so the container doesn't run as root.
# This is important when the container runs in CI or in AWS ECS.
RUN useradd --create-home --shell /bin/bash dbt_user \
    && chown -R dbt_user:dbt_user /usr/app/dbt

USER dbt_user

# The dbt project directory is mounted at runtime via Docker volume.
# See docker-compose.yml for volume mounts and environment variable injection.
ENTRYPOINT ["dbt"]
