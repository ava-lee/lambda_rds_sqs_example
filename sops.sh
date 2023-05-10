export RDS_HOST=$(sops -d secrets.yaml | yq -r .rds.host)
export RDS_ID=$(sops -d secrets.yaml | yq -r .rds.id)
export DB_USER=$(sops -d secrets.yaml | yq -r .rds.user)
export DB_PASS=$(sops -d secrets.yaml | yq -r .rds.password)
export DB_NAME=$(sops -d secrets.yaml | yq -r .rds.db)